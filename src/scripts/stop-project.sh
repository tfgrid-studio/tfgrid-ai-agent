#!/bin/bash
# stop-project.sh - Stop running AI agent loop
# Part of the enhanced AI-Agent workflow

set -e

PROJECT_NAME="$1"

if [ -z "$PROJECT_NAME" ]; then
    echo "Usage: $0 <project-name>"
    echo "Example: $0 my-awesome-project"
    exit 1
fi

if [ ! -d "../$PROJECT_NAME" ]; then
    echo "❌ Error: Project '$PROJECT_NAME' not found"
    exit 1
fi

echo "🛑 Stopping AI agent loop for project: $PROJECT_NAME"

cd "../$PROJECT_NAME"

# Look for running AI agent processes
AGENT_PIDS=$(pgrep -f "agent-loop.sh" 2>/dev/null || true)

if [ -n "$AGENT_PIDS" ]; then
    echo "  killing AI agent processes: $AGENT_PIDS"
    kill $AGENT_PIDS
    echo "✅ AI agent loop stopped"
else
    echo "ℹ️  No running AI agent processes found"
fi