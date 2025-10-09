#!/bin/bash
# run-project.sh - Start AI agent loop for a project
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

echo "🚀 Starting AI agent loop for project: $PROJECT_NAME"
echo "=============================================="

# Get the absolute path to the project directory
PROJECT_PATH="$(cd "../$PROJECT_NAME" && pwd)"

# Start this AI agent loop in background, passing the project directory
nohup bash "$(dirname "$0")/agent-loop.sh" "$PROJECT_PATH" > "$PROJECT_PATH/agent-output.log" 2> "$PROJECT_PATH/agent-errors.log" &
AGENT_PID=$!

echo "✅ AI agent loop started with PID: $AGENT_PID"
echo "📝 Logs are being written to agent-output.log and agent-errors.log"
echo "🛑 To stop the loop, run: make stop"