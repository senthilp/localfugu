# Local Inference Service Plan

## Goal

Make this repository a reproducible setup for downloading an open-weight GGUF model to a local `models/` directory and hosting an OpenAI-compatible inference service on macOS.

## Target Machine

- Apple Silicon Mac, tested target: M4 Max with 128 GB unified memory.
- Default model family: Qwen.
- Default model: `unsloth/Qwen3.6-35B-A3B-GGUF`.
- Default quant: `Qwen3.6-35B-A3B-UD-Q6_K.gguf`.
- Lighter fallback quant: `Qwen3.6-35B-A3B-UD-Q4_K_M.gguf`.

## Progress

- [x] Capture the implementation plan in `PLAN.md`.
- [x] Add model directory structure and Git ignore rules.
- [x] Add environment configuration template.
- [x] Add model download script.
- [x] Add inference server script.
- [x] Add service smoke test script.
- [x] Rewrite `README.md` with clone-to-serve instructions.
- [ ] Optionally download the default model locally after explicit approval.
- [ ] Verify the local service starts and responds to a chat completion request.

## Implementation Steps

1. Add `models/.gitkeep` so the repository has a stable local model directory.
2. Add `.gitignore` rules so large model files and local runtime artifacts are not committed.
3. Add `.env.example` with configurable model, host, port, and context-size settings.
4. Add `scripts/download-model.sh` to download the selected GGUF file from Hugging Face into `models/`.
5. Add `scripts/serve.sh` to start `llama.cpp` against the local GGUF file.
6. Add `scripts/smoke-test.sh` to verify the OpenAI-compatible `/v1/chat/completions` endpoint.
7. Update `README.md` with prerequisites, download, serve, test, and quant-selection instructions.
8. Keep this file updated as each step is completed.

## Expected Commands

Install prerequisites:

```sh
brew install llama.cpp hf
```

Download the default model:

```sh
./scripts/download-model.sh
```

Serve the model:

```sh
./scripts/serve.sh
```

Smoke test:

```sh
./scripts/smoke-test.sh
```

## Notes

- The repository should not commit `.gguf` files. They are too large and should be downloaded locally by each user.
- The default `UD-Q6_K` quant is intended to balance quality and comfort on a 128 GB Apple Silicon Mac.
- The `UD-Q4_K_M` quant should be documented as the lighter fallback for faster startup and lower memory pressure.
- Script syntax has been validated with `bash -n`.
- Host prerequisites were installed with Homebrew: `hf` 1.20.1 and `llama.cpp` 9780.
- The download script supports `DRY_RUN=1` and has confirmed the default GGUF file is available at 29.3 GB.
- The default GGUF has not been downloaded yet, so full service verification remains pending.
