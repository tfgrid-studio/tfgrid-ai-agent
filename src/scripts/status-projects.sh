#!/bin/bash
# status-projects.sh - Show status of all AI agent projects via daemon

set -e

# Source socket client
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/socket-client.sh"

PROJECTS_DIR="/home/developer/code/tfgrid-ai-agent-projects"

echo "📊 AI Agent Projects Status"
echo "=============================="
echo ""

# Get list of running projects from daemon
RESPONSE=$(send_daemon_command "list")
PROJECTS=$(echo "$RESPONSE" | jq -r '.projects[]' 2>/dev/null || true)

if [ -z "$PROJECTS" ]; then
    echo "No projects currently running"
    echo ""
    echo "Create a project: tfgrid-compose create"
    exit 0
fi

# Show each running project
for PROJECT in $PROJECTS; do
    # Get detailed status from daemon
    STATUS_RESPONSE=$(send_daemon_command "status" "$PROJECT")
    PID=$(echo "$STATUS_RESPONSE" | jq -r '.pid // "?"')
    STARTED=$(echo "$STATUS_RESPONSE" | jq -r '.started_at // "unknown"')
    
    # Get additional info from project directory
    PROJECT_PATH="$PROJECTS_DIR/$PROJECT"
    if [ -d "$PROJECT_PATH" ]; then
        # Time constraint
        if [ -f "$PROJECT_PATH/.qwen/config.json" ]; then
            TIME_CONSTRAINT=$(jq -r '.time_constraint // "indefinite"' "$PROJECT_PATH/.qwen/config.json" 2>/dev/null || echo "indefinite")
        else
            TIME_CONSTRAINT="indefinite"
        fi
        
        # Last commit
        if [ -d "$PROJECT_PATH/.git" ]; then
            cd "$PROJECT_PATH"
            LAST_COMMIT=$(git log -1 --format="%cr" 2>/dev/null || echo "no commits")
            cd - > /dev/null
        else
            LAST_COMMIT="no commits"
        fi
    else
        TIME_CONSTRAINT="unknown"
        LAST_COMMIT="unknown"
    fi
    
    # Print project info
    echo "📁 $PROJECT"
    echo "   🟢 Status: Running"
    echo "   🆔 PID: $PID"
    echo "   🕒 Started: $STARTED"
    echo "   ⏱️  Time limit: $TIME_CONSTRAINT"
    echo "   📝 Last commit: $LAST_COMMIT"
    echo "   📂 Logs: $PROJECT_PATH/agent-output.log"
    echo ""
done

echo "🛑 Stop a project: tfgrid-compose stop <project-name>"
echo "🛑 Stop all: tfgrid-compose stopall"
