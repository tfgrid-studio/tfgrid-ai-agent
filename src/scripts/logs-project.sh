#!/bin/bash
# logs-project.sh - View project logs
# Part of the AI-Agent framework

set -e

PROJECT_NAME="$1"
LINES="${2:-50}"  # Default 50 lines
FOLLOW="${3:-true}"  # Default follow mode

if [ -z "$PROJECT_NAME" ]; then
    echo "Usage: $0 <project-name> [lines] [follow]"
    exit 1
fi

PROJECT_PATH="../$PROJECT_NAME"

if [ ! -d "$PROJECT_PATH" ]; then
    echo "❌ Error: Project '$PROJECT_NAME' not found"
    exit 1
fi

cd "$PROJECT_PATH"

# Check what log files exist
OUTPUT_LOG="agent-output.log"
ERROR_LOG="agent-errors.log"

if [ ! -f "$OUTPUT_LOG" ] && [ ! -f "$ERROR_LOG" ]; then
    echo "❌ No log files found for project '$PROJECT_NAME'"
    echo "   (Project may not have been started yet)"
    exit 1
fi

echo "📋 Viewing logs for: $PROJECT_NAME"
echo "   Location: $PROJECT_PATH"
echo ""

# Check if project is running
PROJECT_PID=$(pgrep -f "agent-loop.sh.*$PROJECT_NAME" 2>/dev/null || echo "")
if [ -n "$PROJECT_PID" ]; then
    echo "   Status: 🟢 Running (PID: $PROJECT_PID)"
else
    echo "   Status: ⭕ Stopped"
fi

echo "   Press Ctrl+C to exit"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Show last N lines and follow
if [ "$FOLLOW" = "true" ]; then
    # Follow mode (live tail)
    if [ -f "$OUTPUT_LOG" ]; then
        tail -f -n "$LINES" "$OUTPUT_LOG"
    else
        echo "⚠️  No output log found"
    fi
else
    # Static view
    if [ -f "$OUTPUT_LOG" ]; then
        echo "=== Output Log (last $LINES lines) ==="
        tail -n "$LINES" "$OUTPUT_LOG"
        echo ""
    fi
    
    if [ -f "$ERROR_LOG" ] && [ -s "$ERROR_LOG" ]; then
        echo "=== Error Log ==="
        tail -n "$LINES" "$ERROR_LOG"
        echo ""
    fi
fi
