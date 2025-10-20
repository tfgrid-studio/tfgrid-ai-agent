#!/bin/bash
# run-project.sh - Start AI agent loop via daemon socket
# Sends command to always-running manager daemon

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
        echo "  2. Or: tfgrid-compose run <project-name>"
        exit 1
    fi
fi

# Find project in workspace
PROJECT_PATH=$(find_project_path "$PROJECT_NAME")

if [ -z "$PROJECT_PATH" ]; then
    echo "❌ Error: Project '$PROJECT_NAME' not found"
    echo ""
    echo "Available projects:"
    list_projects_brief
    exit 1
fi

echo "🚀 Starting AI agent loop for project: $PROJECT_NAME"
echo "=============================================="
echo ""

# Check if qwen is authenticated first
echo "🔍 Checking Qwen authentication..."
if ! su - developer -c 'test -f ~/.qwen/settings.json' 2>/dev/null; then
    echo ""
    echo "⚠️  Qwen is not authenticated!"
    echo ""
    echo "Please authenticate first by running:"
    echo "  tfgrid-compose login"
    echo ""
    exit 1
fi

echo "✅ Qwen authenticated"
echo ""

# Send start command to daemon via socket
RESPONSE=$(send_daemon_command "start" "$PROJECT_NAME")

# Parse and display response
STATUS=$(echo "$RESPONSE" | jq -r '.status')

if [ "$STATUS" = "success" ]; then
    PID=$(echo "$RESPONSE" | jq -r '.pid')
    echo "✅ AI agent loop started successfully"
    echo "🔍 Project: $PROJECT_NAME"
    echo "🆔 PID: $PID"
    echo ""
    echo "📝 Logs:"
    echo "  - Output: ${PROJECT_PATH}/agent-output.log"
    echo "  - Errors: ${PROJECT_PATH}/agent-errors.log"
    echo ""
    echo "🛑 To stop: tfgrid-compose stop $PROJECT_NAME"
    echo "📊 To monitor: tfgrid-compose logs $PROJECT_NAME"
else
    MESSAGE=$(echo "$RESPONSE" | jq -r '.message')
    echo "❌ Failed to start project: $MESSAGE"
    exit 1
fi