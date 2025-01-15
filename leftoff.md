# Progress Log

## Completed Tasks
- Updated cuda.Dockerfile to support QVQ-72B model with extended context
- Added special tokens `<|repo_name|>` and `<|file_sep|>` for repository-level code completion
- Created code.gbnf grammar file to support repository structure and code completion
- Configured YARN rope scaling settings for extended context
- Set up tensor splitting for optimal GPU memory usage
- Removed invalid --prompt-cache argument from server configuration
- Confirmed prompt caching is not supported in llama.cpp implementation
- Fixed build workflow to include zip package installation [COMPLETE]
- Updated Dockerfile with correct prompt cache flags (--prompt-cache-all and --prompt-cache-ro) [COMPLETE]
- Removed invalid --prompt-cache argument

## Current Task
- Investigate tensor split configuration

## Next Issues to Fix
1. Validate grammar file loading
4. Validate grammar file loading
5. Test repository-level code completion with example codebase
6. Verify memory usage and GPU layer distribution
7. Validate special token handling with the model
8. Test extended context window performance

## Notes
- Docker container will be built and pushed to ghcr.io/{owner}/llama-cuda:latest and ghcr.io/{owner}/llama-cuda:{commit-sha}
- Container includes QVQ-72B model support with repository-level code completion
- Using CUDA 12.6.0 with optimized tensor splitting (18:18:26:38)
- Using QVQ-72B model from huggingface.co/bartowski/QVQ-72B-Preview-GGUF
- Configured for ChatML format with custom tokens
- Set up with YARN rope scaling (factor: 4.0, base: 32768)
- Removed prompt caching configuration from Hugging Face endpoint
