#!/bin/bash
# restart-project.sh - Restart AI agent loop for a project
# Part of the AI-Agent framework

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

echo "🔄 Restarting project: $PROJECT_NAME"
echo ""

# Check if project is running
PROJECT_PID=$(pgrep -f "agent-loop.sh.*$PROJECT_NAME" 2>/dev/null || echo "")

if [ -n "$PROJECT_PID" ]; then
    echo "🛑 Stopping running instance (PID: $PROJECT_PID)..."
    "$(dirname "$0")/stop-project.sh" "$PROJECT_NAME"
    echo ""
    sleep 2
else
    echo "⚠️  Project was not running"
    echo ""
fi

echo "🚀 Starting project..."
"$(dirname "$0")/run-project.sh" "$PROJECT_NAME"

echo ""
echo "✅ Project '$PROJECT_NAME' restarted successfully"
