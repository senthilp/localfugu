#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

port_override_set=0
if [[ -n "${PORT+x}" ]]; then
  port_override="$PORT"
  port_override_set=1
fi

extra_args_override_set=0
if [[ -n "${LLAMA_EXTRA_ARGS+x}" ]]; then
  extra_args_override="$LLAMA_EXTRA_ARGS"
  extra_args_override_set=1
fi

if [[ -f "$ROOT_DIR/.env" ]]; then
  set -a
  # shellcheck source=/dev/null
  source "$ROOT_DIR/.env"
  set +a
fi

if [[ "$port_override_set" == "1" ]]; then
  PORT="$port_override"
fi

if [[ "$extra_args_override_set" == "1" ]]; then
  LLAMA_EXTRA_ARGS="$extra_args_override"
fi

: "${MODEL_REPO:=unsloth/Qwen3.6-35B-A3B-GGUF}"
: "${MODEL_FILE:=Qwen3.6-35B-A3B-UD-Q6_K.gguf}"
: "${MODEL_DIR:=models/Qwen3.6-35B-A3B-GGUF}"
: "${MODEL_ALIAS:=qwen3.6-35b-a3b}"
: "${HOST:=127.0.0.1}"
: "${PORT:=8080}"
: "${CTX_SIZE:=65536}"
: "${N_GPU_LAYERS:=auto}"

model_path="${MODEL_PATH:-$MODEL_DIR/$MODEL_FILE}"
if [[ "$model_path" != /* ]]; then
  model_path="$ROOT_DIR/$model_path"
fi

if [[ ! -f "$model_path" ]]; then
  cat >&2 <<EOF
Model file not found:
  $model_path

Download it first:
  ./scripts/download-model.sh

Or override MODEL_PATH in .env.
EOF
  exit 1
fi

if [[ -n "${LLAMA_SERVER_BIN:-}" ]]; then
  server_cmd=("$LLAMA_SERVER_BIN")
elif command -v llama-server >/dev/null 2>&1; then
  server_cmd=(llama-server)
elif [[ -x /opt/homebrew/bin/llama-server ]]; then
  server_cmd=(/opt/homebrew/bin/llama-server)
elif command -v llama >/dev/null 2>&1; then
  server_cmd=(llama serve)
elif [[ -x /opt/homebrew/bin/llama ]]; then
  server_cmd=(/opt/homebrew/bin/llama serve)
else
  cat >&2 <<'EOF'
Missing dependency: llama.cpp server

Install it with:
  brew install llama.cpp

Then rerun:
  ./scripts/serve.sh
EOF
  exit 1
fi

server_args=(
  -m "$model_path"
  --alias "$MODEL_ALIAS"
  --host "$HOST"
  --port "$PORT"
  --ctx-size "$CTX_SIZE"
)

if [[ -n "$N_GPU_LAYERS" ]]; then
  server_args+=(--n-gpu-layers "$N_GPU_LAYERS")
fi

if [[ -n "${THREADS:-}" ]]; then
  server_args+=(--threads "$THREADS")
fi

extra_args=()
if [[ -n "${LLAMA_EXTRA_ARGS:-}" ]]; then
  # Intentionally simple: LLAMA_EXTRA_ARGS supports space-separated flags.
  # shellcheck disable=SC2206
  extra_args=(${LLAMA_EXTRA_ARGS})
fi

echo "Starting local inference service"
echo "Model: $model_path"
echo "Endpoint: http://$HOST:$PORT/v1/chat/completions"
echo

if [[ ${#extra_args[@]} -gt 0 ]]; then
  exec "${server_cmd[@]}" "${server_args[@]}" "${extra_args[@]}"
else
  exec "${server_cmd[@]}" "${server_args[@]}"
fi
