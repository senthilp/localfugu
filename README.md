# Local Fugu

Local Fugu is a small, reproducible setup for running an open-weight GGUF language model on macOS and exposing it through a local OpenAI-compatible inference service.

The default target is `unsloth/Qwen3.6-35B-A3B-GGUF` with the `Qwen3.6-35B-A3B-UD-Q6_K.gguf` quant. On an Apple Silicon Mac with 128 GB unified memory, this keeps the model comfortably below total memory while leaving room for normal development work.

## Prerequisites

- macOS on Apple Silicon.
- Homebrew.
- Enough free disk for the selected GGUF file. The default quant is roughly 30 GB.

Install the required CLIs:

```sh
brew install llama.cpp hf
```

If Homebrew is installed but not on your shell `PATH`, use `/opt/homebrew/bin/brew` instead of `brew`.

If `hf` is not available from Homebrew on your machine, install Hugging Face's standalone CLI instead:

```sh
curl -LsSf https://hf.co/cli/install.sh | bash
```

## Quick Start

Clone the repo, then from the repo root:

```sh
cp .env.example .env
DRY_RUN=1 ./scripts/download-model.sh
./scripts/download-model.sh
./scripts/serve.sh
```

In another terminal:

```sh
./scripts/smoke-test.sh
```

The service listens on:

```text
http://127.0.0.1:8080/v1/chat/completions
```

## Configuration

Edit `.env` to change model, quant, host, port, or context size.

Default:

```sh
MODEL_REPO=unsloth/Qwen3.6-35B-A3B-GGUF
MODEL_FILE=Qwen3.6-35B-A3B-UD-Q6_K.gguf
MODEL_DIR=models/Qwen3.6-35B-A3B-GGUF
CTX_SIZE=65536
```

For a lighter setup, switch to:

```sh
MODEL_FILE=Qwen3.6-35B-A3B-UD-Q4_K_M.gguf
CTX_SIZE=32768
```

## Scripts

`scripts/download-model.sh` downloads the configured GGUF file into `models/`.

Run `DRY_RUN=1 ./scripts/download-model.sh` to confirm the file and size before downloading.

`scripts/serve.sh` starts `llama.cpp` against the local model file.

`scripts/smoke-test.sh` sends a minimal chat completion request to confirm the server is responding.

## Model Files

Model files are intentionally not committed to Git. Each machine downloads its own copy under `models/`.

Ignored local artifacts include:

- `.env`
- `models/**/*.gguf`
- Hugging Face local download metadata under `models/**/.cache/`
