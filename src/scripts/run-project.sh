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
if [ ! -f "$HOME/.qwen/settings.json" ]; then
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

# Start the agent loop directly in background (avoid systemctl to prevent SSH issues)
echo "🚀 Starting AI agent loop for project: $PROJECT_NAME"

# Start in background with nohup to survive SSH disconnection
cd "$PROJECT_PATH"
nohup /opt/ai-agent/scripts/agent-loop.sh "$PROJECT_PATH" > agent-output.log 2> agent-errors.log &
AGENT_PID=$!

# Save PID for later management
echo "$AGENT_PID" > "$PROJECT_PATH/.agent/pid"

# Wait a moment to check if it started successfully
sleep 1
if kill -0 "$AGENT_PID" 2>/dev/null; then
    echo "✅ AI agent loop started with PID: $AGENT_PID"
    echo "📝 Logs are being written to:"
    echo "    - ${PROJECT_PATH}/agent-output.log"
    echo "    - ${PROJECT_PATH}/agent-errors.log"
    echo ""
    echo "🛑 To stop: kill $AGENT_PID"
    echo "📊 To monitor: tail -f ${PROJECT_PATH}/agent-output.log"
else
    echo "❌ Failed to start agent loop"
    echo ""
    echo "Check logs at: ${PROJECT_PATH}/agent-errors.log"
    exit 1
fi