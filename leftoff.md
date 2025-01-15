# Progress Log

## Completed Tasks
- Updated cuda.Dockerfile to support QVQ-72B model with extended context
- Added special tokens `<|repo_name|>` and `<|file_sep|>` for repository-level code completion
- Created code.gbnf grammar file to support repository structure and code completion
- Configured YARN rope scaling settings for extended context
- Set up tensor splitting for optimal GPU memory usage
- Fixed build workflow to include zip package installation
- Fixed prompt cache configuration in Dockerfile after code analysis:
  - Removed `--prompt-cache-ro` flag temporarily for simplification
  - Set `LLAMA_PROMPT_CACHE` environment variable to `/app/cache/prompt_cache`
  - Updated `ENTRYPOINT` to construct the server command using individual environment variables, including `--prompt-cache $LLAMA_PROMPT_CACHE`
  - Confirmed --prompt-cache-all is not compatible with interactive mode
  - Fixed argument parsing issue by using a simpler prompt cache path and constructing the argument in the `ENTRYPOINT`
- Added `echo` command to `ENTRYPOINT` to print the constructed server command for debugging purposes
& git push
- Fixed missing libllama.so by adding LD_LIBRARY_PATH to Dockerfile
- Rebuilt llama-cuda:debug image and verified libllama.so is found

## Current Task
- Fixed prompt cache directory issue in Dockerfile
- Next: Download and integrate QVQ-72B model from huggingface.co/lmstudio-community/QVQ-72B-Preview-GGUF

## Next Issues to Fix
1. Download QVQ-72B model from huggingface.co/lmstudio-community/QVQ-72B-Preview-GGUF
2. Test grammar validation with sample code
3. Test repository-level code completion with example codebase
4. Verify memory usage and GPU layer distribution
5. Validate special token handling with the model
6. Test extended context window performance

## Required Steps
1. Download QVQ-72B model from huggingface.co/lmstudio-community/QVQ-72B-Preview-GGUF
2. Mount model file and cache directory when running container:
   ```bash
   docker run -v /path/to/QVQ-72B.gguf:/app/llama.cpp/models/model.gguf -v /path/to/cache:/app/llama.cpp/cache llama-cuda:debug
   ```
3. Verify server starts successfully with model loaded

## Completed Tasks
- Updated cuda.Dockerfile to support QVQ-72B model with extended context
- Added special tokens `<|repo_name|>` and `<|file_sep|>` for repository-level code completion
- Created code.gbnf grammar file to support repository structure and code completion
- Configured YARN rope scaling settings for extended context
- Set up tensor splitting for optimal GPU memory usage
- Rebuilt llama-cuda:debug image and verified libllama.so is found
- Validated grammar file loading

## Notes
- Docker container will be built and pushed to ghcr.io/{owner}/llama-cuda:latest and ghcr.io/{owner}/llama-cuda:{commit-sha}
- Container includes QVQ-72B model support with repository-level code completion
- Using CUDA 12.6.0 with optimized tensor splitting (18:18:26:38)
- Using QVQ-72B model from huggingface.co/bartowski/QVQ-72B-Preview-GGUF
- Configured for ChatML format with custom tokens
- Set up with YARN rope scaling (factor: 4.0, base: 32768)
- Prompt cache configured with a simple path using an environment variable in the `ENTRYPOINT`
- Added `echo` to `ENTRYPOINT` to print the server command for debugging
- Added LD_LIBRARY_PATH to ensure shared libraries are found at runtime
