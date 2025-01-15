# Progress Log

## Completed Tasks
- Updated cuda.Dockerfile to support QVQ-72B model with extended context
- Added special tokens `<|repo_name|>` and `<|file_sep|>` for repository-level code completion
- Created code.gbnf grammar file to support repository structure and code completion
- Configured YARN rope scaling settings for extended context
- Set up tensor splitting for optimal GPU memory usage
- Fixed build workflow to include zip package installation
- Fixed prompt cache configuration in Dockerfile after code analysis:
  - Added explicit --prompt-cache path to /app/cache/prompt.bin
  - Added --prompt-cache-ro flag for read-only operation in server environment
  - Confirmed --prompt-cache-all is not compatible with interactive mode
  - Verified prompt cache implementation in args.cpp

## Current Task
- Test server startup with updated prompt cache configuration

## Next Issues to Fix
1. Validate grammar file loading
2. Test repository-level code completion with example codebase
3. Verify memory usage and GPU layer distribution
4. Validate special token handling with the model
5. Test extended context window performance

## Notes
- Docker container will be built and pushed to ghcr.io/{owner}/llama-cuda:latest and ghcr.io/{owner}/llama-cuda:{commit-sha}
- Container includes QVQ-72B model support with repository-level code completion
- Using CUDA 12.6.0 with optimized tensor splitting (18:18:26:38)
- Using QVQ-72B model from huggingface.co/bartowski/QVQ-72B-Preview-GGUF
- Configured for ChatML format with custom tokens
- Set up with YARN rope scaling (factor: 4.0, base: 32768)
- Prompt cache configured for read-only server operation with explicit cache file path
