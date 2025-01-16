# Progress Log

## Completed Tasks
- Updated cuda.Dockerfile to support QVQ-72B model with extended context
- Added special tokens `<|repo_name|>` and `<|file_sep|>` for repository-level code completion
- Created code.gbnf grammar file to support repository structure and code completion
- Configured YARN rope scaling settings for extended context
- Set up tensor splitting for optimal GPU memory usage
- Fixed build workflow to include zip package installation
- Fixed missing libllama.so by adding LD_LIBRARY_PATH to Dockerfile
- Rebuilt llama-cuda:debug image and verified libllama.so is found
- Investigated prompt cache configuration:
  - Found proper prompt cache arguments in arg.cpp:
    * --prompt-cache FNAME: Path to cache prompt state for faster startup
    * --prompt-cache-all: Save user input and generations to cache
    * --prompt-cache-ro: Use prompt cache but don't update it
  - Removed prompt cache from Dockerfile as it's better configured at runtime
  - Note: prompt-cache-all is not compatible with interactive mode
- Fixed server startup issue by removing prompt cache configuration from Dockerfile
- Fixed NUMA configuration in Dockerfile:
  - Changed LLAMA_NUMA=1 to LLAMA_NUMA=distribute
  - Updated server command to use --numa distribute for proper NUMA strategy
  - This spreads execution evenly over all nodes for better performance
- Removed unsupported --custom-token argument:
  - Removed LLAMA_CUSTOM_TOKEN environment variable
  - Removed --custom-token flag from server command
  - Note: Need to investigate alternative way to handle special tokens

## Current Task
- Next: Download and integrate QVQ-72B model from huggingface.co/lmstudio-community/QVQ-72B-Preview-GGUF

## Next Issues to Fix
1. Download QVQ-72B model from huggingface.co/lmstudio-community/QVQ-72B-Preview-GGUF
2. Test grammar validation with sample code
3. Test repository-level code completion with example codebase
4. Verify memory usage and GPU layer distribution
5. Investigate and implement alternative method for special token handling
6. Test extended context window performance

## Required Steps
1. Download QVQ-72B model from huggingface.co/lmstudio-community/QVQ-72B-Preview-GGUF
2. Mount model file and cache directory when running container:
   ```bash
   docker run -v /path/to/QVQ-72B.gguf:/app/llama.cpp/models/model.gguf -v /path/to/cache:/app/llama.cpp/cache llama-cuda:debug
   ```
3. Verify server starts successfully with model loaded

## Notes
- Docker container will be built and pushed to ghcr.io/{owner}/llama-cuda:latest and ghcr.io/{owner}/llama-cuda:{commit-sha}
- Container includes QVQ-72B model support with repository-level code completion
- Using CUDA 12.6.0 with optimized tensor splitting (18:18:26:38)
- Using QVQ-72B model from huggingface.co/bartowski/QVQ-72B-Preview-GGUF
- Configured for ChatML format with custom tokens
- Set up with YARN rope scaling (factor: 4.0, base: 32768)
- Added LD_LIBRARY_PATH to ensure shared libraries are found at runtime
- Prompt cache should be configured at runtime using:
  * --prompt-cache for basic caching
  * --prompt-cache-all to also cache user input/generations
  * --prompt-cache-ro for read-only cache access
