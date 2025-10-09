#!/bin/bash
# remove-project.sh - Remove a project (with confirmation)
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

echo "⚠️  WARNING: This will permanently delete:"
echo ""
echo "  Directory: $PROJECT_PATH"
echo "  - All source files"
echo "  - Git history"
echo "  - Agent logs and metadata"
echo ""
echo "  This action CANNOT be undone!"
echo ""

# Check if project is running
PROJECT_PID=$(pgrep -f "agent-loop.sh.*$PROJECT_NAME" 2>/dev/null || echo "")
if [ -n "$PROJECT_PID" ]; then
    echo "⚠️  Project is currently running (PID: $PROJECT_PID)"
    read -p "Stop it before deletion? (y/N): " stop_it
    if [ "$stop_it" = "y" ] || [ "$stop_it" = "Y" ]; then
        echo "🛑 Stopping project..."
        "$(dirname "$0")/stop-project.sh" "$PROJECT_NAME" || true
        sleep 1
    else
        echo "❌ Cannot delete running project. Stop it first with: make stop"
        exit 1
    fi
fi

# Require typing project name to confirm
echo "Type the project name '$PROJECT_NAME' to confirm deletion:"
read -r confirmation

if [ "$confirmation" != "$PROJECT_NAME" ]; then
    echo "❌ Confirmation failed. Deletion cancelled."
    exit 1
fi

echo ""
echo "🗑️  Deleting project '$PROJECT_NAME'..."

# Remove the directory
rm -rf "$PROJECT_PATH"

echo "✅ Project '$PROJECT_NAME' has been permanently deleted"
