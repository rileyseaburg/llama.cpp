ARG UBUNTU_VERSION=22.04
# This needs to generally match the container host's environment.
ARG CUDA_VERSION=12.6.0
# Target the CUDA build image
ARG BASE_CUDA_DEV_CONTAINER=nvidia/cuda:${CUDA_VERSION}-devel-ubuntu${UBUNTU_VERSION}

ARG BASE_CUDA_RUN_CONTAINER=nvidia/cuda:${CUDA_VERSION}-runtime-ubuntu${UBUNTU_VERSION}

FROM ${BASE_CUDA_DEV_CONTAINER} AS build

# CUDA architecture to build for (defaults to all supported archs)
ARG CUDA_DOCKER_ARCH=default

RUN apt-get update && \
    apt-get install -y build-essential cmake python3 python3-pip git libcurl4-openssl-dev libgomp1

WORKDIR /app/llama.cpp

COPY ../ . .

RUN if [ "${CUDA_DOCKER_ARCH}" != "default" ]; then \
    export CMAKE_ARGS="-DCMAKE_CUDA_ARCHITECTURES=${CUDA_DOCKER_ARCH}"; \
    fi && \
    cmake -B build -DGGML_NATIVE=OFF -DGGML_CUDA=ON -DLLAMA_CURL=ON ${CMAKE_ARGS} -DCMAKE_EXE_LINKER_FLAGS=-Wl,--allow-shlib-undefined . && \
    cmake --build build --config Release -j$(nproc)

RUN mkdir -p /app/llama.cpp/lib && \
    find build -name "*.so" -exec cp {} /app/llama.cpp/lib \;

RUN mkdir -p /app/llama.cpp/full \
    && cp build/bin/* /app/llama.cpp/full \
    && cp *.py /app/llama.cpp/full \
    && cp -r gguf-py /app/llama.cpp/full \
    && cp -r requirements /app/llama.cpp/full \
    && cp requirements.txt /app/llama.cpp/full \
    && cp .devops/tools.sh /app/llama.cpp/full/tools.sh

## Base image
FROM ${BASE_CUDA_RUN_CONTAINER} AS base

ENV LD_LIBRARY_PATH=/app/llama.cpp/lib:${LD_LIBRARY_PATH}

RUN apt-get update \
    && apt-get install -y libgomp1 curl\
    && apt autoremove -y \
    && apt clean -y \
    && rm -rf /tmp/* /var/tmp/* \
    && find /var/cache/apt/archives /var/lib/apt/lists -not -name lock -type f -delete \
    && find /var/cache -type f -delete

COPY --from=build /app/llama.cpp/lib/ /app/llama.cpp/lib/

### Full
FROM base AS full

COPY --from=build /app/llama.cpp/full /app/llama.cpp/

WORKDIR /app/llama.cpp

RUN apt-get update \
    && apt-get install -y \
    git \
    python3 \
    python3-pip \
    && pip install --upgrade pip setuptools wheel \
    && pip install -r requirements.txt \
    && apt autoremove -y \
    && apt clean -y \
    && rm -rf /tmp/* /var/tmp/* \
    && find /var/cache/apt/archives /var/lib/apt/lists -not -name lock -type f -delete \
    && find /var/cache -type f -delete

ENTRYPOINT ["/app/llama.cpp/tools.sh"]

### Light, CLI only
FROM base AS light

COPY --from=build /app/llama.cpp/full/llama-cli /app/llama.cpp/

WORKDIR /app/llama.cpp

ENTRYPOINT [ "/app/llama.cpp/llama-cli" ]

### Server, Server only
FROM base AS server

ENV LLAMA_N_GPU_LAYERS=40
ENV LLAMA_CTX_SIZE=131072
ENV LLAMA_THREADS=16
ENV LLAMA_ROPE_FREQ_BASE=32768
ENV LLAMA_ROPE_SCALE=4.0
ENV LLAMA_PROMPT_CACHE=/app/llama.cpp/cache
ENV LLAMA_CHAT_TEMPLATE=chatml
ENV LLAMA_GRAMMAR_FILE=/app/llama.cpp/grammars/code.gbnf
ENV LLAMA_MLOCK=1
ENV LLAMA_NUMA=1
ENV LLAMA_TENSOR_SPLIT=18:18:26:38
ENV LLAMA_CUSTOM_TOKEN="<|repo_name|><|file_sep|>"
ENV LLAMA_MODEL=/app/llama.cpp/models/model.gguf

COPY --from=build /app/llama.cpp/full/llama-server /app/llama.cpp/
COPY --from=build /app/llama.cpp/grammars/code.gbnf /app/llama.cpp/grammars/

WORKDIR /app/llama.cpp

# Create required directories with appropriate permissions
RUN mkdir -p /app/llama.cpp/cache /app/llama.cpp/models && chmod 777 /app/llama.cpp/cache /app/llama.cpp/models

HEALTHCHECK CMD [ "curl", "-f", "http://localhost:8080/health" ]

ENTRYPOINT [ "sh", "-c", "echo 'Debug: Library paths and files:' && \
echo 'LD_LIBRARY_PATH=' $LD_LIBRARY_PATH && \
echo 'Contents of /app/llama.cpp/lib:' && \
ls -la /app/llama.cpp/lib && \
echo 'Running ldd on server binary:' && \
ldd /app/llama.cpp/llama-server && \
echo 'Starting server with command:' && \
echo /app/llama.cpp/llama-server -m $LLAMA_MODEL --n-gpu-layers $LLAMA_N_GPU_LAYERS --ctx-size $LLAMA_CTX_SIZE --threads $LLAMA_THREADS --rope-freq-base $LLAMA_ROPE_FREQ_BASE --rope-scale $LLAMA_ROPE_SCALE --grammar-file $LLAMA_GRAMMAR_FILE --prompt-cache $LLAMA_PROMPT_CACHE --mlock --numa --tensor-split $LLAMA_TENSOR_SPLIT --custom-token $LLAMA_CUSTOM_TOKEN && \
/app/llama.cpp/llama-server -m $LLAMA_MODEL --n-gpu-layers $LLAMA_N_GPU_LAYERS --ctx-size $LLAMA_CTX_SIZE --threads $LLAMA_THREADS --rope-freq-base $LLAMA_ROPE_FREQ_BASE --rope-scale $LLAMA_ROPE_SCALE --grammar-file $LLAMA_GRAMMAR_FILE --prompt-cache $LLAMA_PROMPT_CACHE --mlock --numa --tensor-split $LLAMA_TENSOR_SPLIT --custom-token $LLAMA_CUSTOM_TOKEN" ]

# Usage: Mount your GGUF model file when running the container:
# docker run -v /path/to/your/model.gguf:/app/llama.cpp/models/model.gguf llama-cuda:debug
