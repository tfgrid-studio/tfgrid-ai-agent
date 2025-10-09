#!/bin/bash
# monitor-project.sh - Monitor project progress
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

echo "📊 Monitoring project: $PROJECT_NAME"
echo "==============================="

cd "../$PROJECT_NAME"

if [ -f "agent-output.log" ]; then
    echo "📄 Recent output log entries:"
    tail -20 agent-output.log
    echo ""
fi

if [ -f "agent-errors.log" ]; then
    ERROR_COUNT=$(wc -l < agent-errors.log 2>/dev/null || echo "0")
    if [ "$ERROR_COUNT" -gt 0 ]; then
        echo "⚠️  Error log entries ($ERROR_COUNT lines):"
        tail -10 agent-errors.log
        echo ""
    fi
fi

if [ -f ".agent/TODO.md" ]; then
    echo "📋 Current TODO status:"
    grep -A 5 "## Status" .agent/TODO.md | head -6
    echo ""
fi

echo "💾 Git status:"
git status --porcelain | wc -l | xargs -I {} echo "{} uncommitted changes"

echo "📈 Project directory size:"
du -sh . | cut -f1