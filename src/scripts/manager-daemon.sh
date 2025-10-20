#!/bin/bash
# TFGrid AI Agent Manager Daemon
# Always-running daemon that manages multiple AI agent projects via Unix socket

set -euo pipefail

SOCKET_PATH="/var/run/ai-agent.sock"
STATE_FILE="/var/lib/ai-agent/projects.json"
HANDLER_WRAPPER="/opt/ai-agent/scripts/socket-handler-wrapper.sh"

# Cleanup on exit
cleanup() {
    echo "$(date): Shutting down AI Agent Manager..."
    rm -f "$SOCKET_PATH"
}
trap cleanup EXIT SIGTERM SIGINT

# Ensure state directory exists
mkdir -p "$(dirname "$STATE_FILE")"

# Initialize state file if needed
if [ ! -f "$STATE_FILE" ]; then
    echo '{}' > "$STATE_FILE"
    chmod 644 "$STATE_FILE"
fi

# Remove stale socket if exists
rm -f "$SOCKET_PATH"

# Start socket listener with fork model
# Each connection spawns independent handler process  
echo "$(date): Starting AI Agent Manager on $SOCKET_PATH"
exec socat UNIX-LISTEN:"$SOCKET_PATH",fork,mode=0600 EXEC:"$HANDLER_WRAPPER"
