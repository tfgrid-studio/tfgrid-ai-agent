#!/bin/bash
# Simpler daemon using nc and while loop

set -euo pipefail

SOCKET_PATH="/run/ai-agent.sock"
STATE_FILE="/var/lib/ai-agent/projects.json"
HANDLER="/opt/ai-agent/scripts/handle-command.sh"

# Cleanup
cleanup() {
    echo "$(date): Shutting down..."
    rm -f "$SOCKET_PATH"
}
trap cleanup EXIT SIGTERM SIGINT

# Setup
mkdir -p "$(dirname "$STATE_FILE")"
[ ! -f "$STATE_FILE" ] && echo '{}' > "$STATE_FILE"
rm -f "$SOCKET_PATH"

echo "$(date): Starting AI Agent Manager on $SOCKET_PATH"

# Simple loop with nc
while true; do
    nc -lU "$SOCKET_PATH" | "$HANDLER" | nc -U "$SOCKET_PATH" || true
    sleep 0.1
done
