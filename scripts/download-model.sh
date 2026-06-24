#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

if [[ -f "$ROOT_DIR/.env" ]]; then
  set -a
  # shellcheck source=/dev/null
  source "$ROOT_DIR/.env"
  set +a
fi

: "${MODEL_REPO:=unsloth/Qwen3.6-35B-A3B-GGUF}"
: "${MODEL_FILE:=Qwen3.6-35B-A3B-UD-Q6_K.gguf}"
: "${MODEL_DIR:=models/Qwen3.6-35B-A3B-GGUF}"

if command -v hf >/dev/null 2>&1; then
  hf_bin="$(command -v hf)"
elif [[ -x /opt/homebrew/bin/hf ]]; then
  hf_bin="/opt/homebrew/bin/hf"
else
  cat >&2 <<'EOF'
Missing dependency: hf

Install it with one of:
  brew install hf
  curl -LsSf https://hf.co/cli/install.sh | bash

Then rerun:
  ./scripts/download-model.sh
EOF
  exit 1
fi

mkdir -p "$MODEL_DIR"

args=(download "$MODEL_REPO" "$MODEL_FILE" --local-dir "$MODEL_DIR")
if [[ -n "${HF_REVISION:-}" ]]; then
  args+=(--revision "$HF_REVISION")
fi

echo "Downloading $MODEL_REPO/$MODEL_FILE"
echo "Destination: $MODEL_DIR"

if [[ "${DRY_RUN:-0}" == "1" || "${DRY_RUN:-}" == "true" ]]; then
  echo "Mode: dry run"
  "$hf_bin" "${args[@]}" --dry-run
  exit 0
fi

"$hf_bin" "${args[@]}"

model_path="$MODEL_DIR/$MODEL_FILE"
if [[ ! -f "$model_path" ]]; then
  echo "Download finished, but expected model file was not found: $model_path" >&2
  exit 1
fi

echo
echo "Model ready: $model_path"
du -h "$model_path" | awk '{print "Size: " $1}'
