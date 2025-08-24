
#### `scripts/healthcheck_ui.sh`
```bash
#!/usr/bin/env bash
set -euo pipefail

HOST="${1:-localhost}"
PORT="${2:-8080}"

for i in $(seq 1 24); do
  if curl -fsS "http://${HOST}:${PORT}/" >/dev/null; then
    echo "UI OK en http://${HOST}:${PORT}"
    exit 0
  fi
  echo "UI no disponible aún, reintentando ($i/24)..."
  sleep 5
done

echo "ERROR: UI no respondió a tiempo" >&2
exit 1
