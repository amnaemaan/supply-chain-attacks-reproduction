#!/usr/bin/env bash
# demo-setup.sh — Start Verdaccio & publisher, wait for publish, then build vulnerable image
set -euo pipefail

# Start Verdaccio and the publisher (they will publish the attacker package to Verdaccio)
echo "Starting Verdaccio + publisher..."
docker compose up -d verdaccio publisher

# Wait for Verdaccio to be ready (responding to /-/ping)
echo "Waiting for Verdaccio to respond..."
until curl -sS http://localhost:4873/-/ping >/dev/null 2>&1; do
  printf "."
  sleep 1
done
echo
echo "Verdaccio is up."

# Give publisher a short window to publish (check its logs)
echo "Waiting 2s for publisher to publish..."
sleep 2
echo "Publisher logs (last 200 lines):"
docker logs publisher --tail 200 || true

# Build & start the vulnerable-builder (now that Verdaccio has the package)
echo "Building and starting vulnerable-builder..."
docker compose up --build -d vulnerable-builder

# Show instructions for verification
echo
echo "Done. To follow the vulnerable-builder logs run:"
echo "  docker compose logs -f vulnerable-builder"
echo
echo "To check the pwned file inside the running container:"
echo "  docker exec -it vulnerable-builder sh -c 'ls -la /tmp && cat /tmp/pwned.txt || echo \"pwned.txt not present\"'"
