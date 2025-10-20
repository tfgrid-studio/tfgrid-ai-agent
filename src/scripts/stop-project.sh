#!/bin/bash
# stop-project.sh - Stop AI agent loop via daemon socket

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common-project.sh"
source "$SCRIPT_DIR/socket-client.sh"

PROJECT_NAME="$1"

# If no argument, try to get from context
if [ -z "$PROJECT_NAME" ]; then
    CONTEXT_FILE="$HOME/.config/tfgrid-compose/context.yaml"
    
    if [ -f "$CONTEXT_FILE" ]; then
        PROJECT_NAME=$(grep "^active_project:" "$CONTEXT_FILE" 2>/dev/null | awk '{print $2}')
    fi
    
    if [ -z "$PROJECT_NAME" ]; then
        echo "❌ No project specified and no project selected"
        echo ""
        echo "Either:"
        echo "  1. Run: tfgrid-compose select-project"
        echo "  2. Or: tfgrid-compose stop <project-name>"
        exit 1
    fi
fi

echo "🛑 Stopping AI agent loop for project: $PROJECT_NAME"

# Send stop command to daemon via socket
RESPONSE=$(send_daemon_command "stop" "$PROJECT_NAME")

# Parse response
STATUS=$(echo "$RESPONSE" | jq -r '.status')

if [ "$STATUS" = "success" ]; then
    echo "✅ AI agent loop stopped for: $PROJECT_NAME"
else
    MESSAGE=$(echo "$RESPONSE" | jq -r '.message')
    echo "❌ Failed to stop: $MESSAGE"
    exit 1
fi