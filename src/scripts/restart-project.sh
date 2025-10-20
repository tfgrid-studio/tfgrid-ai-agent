#!/bin/bash
# restart-project.sh - Restart AI agent loop for a project via systemd

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

# Use systemd restart (--no-block to avoid hanging over SSH)
if systemctl restart --no-block "tfgrid-ai-project@${PROJECT_NAME}.service" 2>/dev/null; then
    sleep 2
    
    if systemctl is-active --quiet "tfgrid-ai-project@${PROJECT_NAME}.service"; then
        PID=$(systemctl show -p MainPID --value "tfgrid-ai-project@${PROJECT_NAME}.service")
        echo "✅ Project '$PROJECT_NAME' restarted successfully"
        echo "🆔 PID: $PID"
        echo ""
        echo "📊 Monitor: tfgrid-compose monitor $PROJECT_NAME"
        echo "📝 Logs: tfgrid-compose logs $PROJECT_NAME"
    else
        echo "⚠️  Service restart initiated (may still be starting)"
        echo ""
        echo "Check status: tfgrid-compose projects"
    fi
else
    echo "❌ Failed to restart service"
    exit 1
fi
