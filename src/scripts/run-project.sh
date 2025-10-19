#!/bin/bash
# run-project.sh - Start AI agent loop for a project using systemd
# Part of the enhanced AI-Agent workflow

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common-project.sh"

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
if [ ! -f "$HOME/.qwen/config.yaml" ] && [ ! -f "$HOME/.config/qwen/config.yaml" ]; then
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

# Use systemd-run to start the project (doesn't require daemon-reload!)
# This creates a transient service unit on-the-fly
echo "🚀 Starting agent loop..."
systemd-run --unit="tfgrid-ai-project-${PROJECT_NAME}" \
    --working-directory="$PROJECT_PATH" \
    --property="User=developer" \
    --property="Group=developer" \
    --property="Restart=on-failure" \
    --property="RestartSec=10" \
    --property="StandardOutput=append:${PROJECT_PATH}/agent-output.log" \
    --property="StandardError=append:${PROJECT_PATH}/agent-errors.log" \
    /opt/ai-agent/scripts/agent-loop.sh "$PROJECT_PATH"

# Wait a moment and check if started successfully
sleep 1
UNIT_NAME="tfgrid-ai-project-${PROJECT_NAME}.service"
if systemctl is-active --quiet "$UNIT_NAME"; then
    PID=$(systemctl show -p MainPID --value "$UNIT_NAME")
    echo "✅ AI agent loop started with PID: $PID"
    echo "📝 Logs are being written to agent-output.log and agent-errors.log"
    echo "🛑 To stop: systemctl stop $UNIT_NAME"
else
    echo "❌ Failed to start project: $PROJECT_NAME"
    echo ""
    echo "Recent logs:"
    journalctl -u "$UNIT_NAME" -n 20 --no-pager
    exit 1
fi