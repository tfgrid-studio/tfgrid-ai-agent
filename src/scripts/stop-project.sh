#!/bin/bash
# stop-project.sh - Stop AI agent loop for a project
# Part of the enhanced AI-Agent workflow

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common-project.sh"

PROJECT_NAME="$1"

if [ -z "$PROJECT_NAME" ]; then
    echo "Usage: $0 <project-name>"
    exit 1
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

echo "🛑 Stopping AI agent loop for project: $PROJECT_NAME"

cd "$PROJECT_PATH"

# Look for running AI agent processes
AGENT_PIDS=$(pgrep -f "agent-loop.sh" 2>/dev/null || true)

if [ -n "$AGENT_PIDS" ]; then
    echo "  killing AI agent processes: $AGENT_PIDS"
    kill $AGENT_PIDS
    echo "✅ AI agent loop stopped"
else
    echo "ℹ️  No running AI agent processes found"
fi