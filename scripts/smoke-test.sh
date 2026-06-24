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

: "${HOST:=127.0.0.1}"
: "${PORT:=8080}"
: "${MODEL_ALIAS:=qwen3.6-35b-a3b}"

if ! command -v curl >/dev/null 2>&1; then
  echo "Missing dependency: curl" >&2
  exit 1
fi

url="http://$HOST:$PORT/v1/chat/completions"
body_file="$(mktemp)"
trap 'rm -f "$body_file"' EXIT

payload="$(cat <<JSON
{
  "model": "$MODEL_ALIAS",
  "messages": [
    {
      "role": "user",
      "content": "Reply with exactly: ok"
    }
  ],
  "temperature": 0,
  "max_tokens": 16
}
JSON
)"

echo "POST $url"
if ! status="$(
  curl -sS \
    -o "$body_file" \
    -w "%{http_code}" \
    -H "Content-Type: application/json" \
    -d "$payload" \
    "$url"
)"; then
  echo "Smoke test could not reach the server. Start it first with:" >&2
  echo "  ./scripts/serve.sh" >&2
  exit 1
fi

if [[ -s "$body_file" ]]; then
  cat "$body_file"
else
  echo "<empty response body>"
fi
echo

if [[ "$status" != 2* ]]; then
  echo "Smoke test failed with HTTP $status" >&2
  exit 1
fi

echo "Smoke test passed with HTTP $status"
