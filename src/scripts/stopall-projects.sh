#!/bin/bash
# stopall-projects.sh - Stop all running AI agent loops via daemon

set -e

# Source socket client
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/socket-client.sh"

echo "🛑 Stopping All AI Agent Loops"
echo "=============================="
echo ""

# Get list of running projects from daemon
RESPONSE=$(send_daemon_command "list")
PROJECTS=$(echo "$RESPONSE" | jq -r '.projects[]' 2>/dev/null || true)

if [ -z "$PROJECTS" ]; then
    echo "✅ No running projects found"
    exit 0
fi

# Count projects
PROJECT_COUNT=$(echo "$PROJECTS" | wc -l)

# Display running projects
echo "Found $PROJECT_COUNT running project(s):"
echo ""
for PROJECT in $PROJECTS; do
    echo "  - $PROJECT"
done
echo ""

# Confirm (skip in non-interactive mode)
if [ -t 0 ]; then
    read -p "Stop all projects? (y/N): " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo "❌ Cancelled"
        exit 0
    fi
    echo ""
fi

echo "🛑 Stopping all projects..."
echo ""

# Stop each project via daemon
for PROJECT in $PROJECTS; do
    echo "  Stopping: $PROJECT"
    RESPONSE=$(send_daemon_command "stop" "$PROJECT")
    STATUS=$(echo "$RESPONSE" | jq -r '.status')
    if [ "$STATUS" = "success" ]; then
        echo "    ✅ Stopped"
    else
        echo "    ❌ Failed: $(echo "$RESPONSE" | jq -r '.message')"
    fi
done

echo ""
echo "✅ All projects stopped successfully"
