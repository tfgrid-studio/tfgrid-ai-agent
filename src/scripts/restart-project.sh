#!/bin/bash
# restart-project.sh - Restart a running project
# Part of the AI-Agent framework

set -e

PROJECT_NAME="$1"

if [ -z "$PROJECT_NAME" ]; then
    echo "Usage: $0 <project-name>"
    exit 1
fi

PROJECT_PATH="../$PROJECT_NAME"

if [ ! -d "$PROJECT_PATH" ]; then
    echo "❌ Error: Project '$PROJECT_NAME' not found"
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
