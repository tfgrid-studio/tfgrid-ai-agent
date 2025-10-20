#!/bin/bash
# Command handler - forked per socket connection by socat
# Handles: start, stop, status, list commands

set -euo pipefail

STATE_FILE="/var/lib/ai-agent/projects.json"
LOCK_FILE="/var/lock/ai-agent-state.lock"
PROJECTS_DIR="/home/developer/code/tfgrid-ai-agent-projects"

# Read JSON request from stdin (single line)
read -r REQUEST

# Parse with jq
ACTION=$(echo "$REQUEST" | jq -r '.action // empty')
PROJECT=$(echo "$REQUEST" | jq -r '.project // empty')

# Validate input
if [ -z "$ACTION" ]; then
    echo '{"status":"error","message":"Missing action field"}'
    exit 0
fi

# Execute command
case "$ACTION" in
    start)
        if [ -z "$PROJECT" ]; then
            echo '{"status":"error","message":"Missing project name"}'
            exit 0
        fi
        
        # Check if project directory exists
        if [ ! -d "$PROJECTS_DIR/$PROJECT" ]; then
            echo '{"status":"error","message":"Project not found: '"$PROJECT"'"}'
            exit 0
        fi
        
        # Check if already running
        if systemctl is-active --quiet "tfgrid-ai-project@${PROJECT}.service"; then
            echo '{"status":"error","message":"Project already running"}'
            exit 0
        fi
        
        # Start service (no SSH context!)
        if systemctl start "tfgrid-ai-project@${PROJECT}.service" 2>/dev/null; then
            # Wait a moment for startup
            sleep 1
            
            # Verify started successfully
            if systemctl is-active --quiet "tfgrid-ai-project@${PROJECT}.service"; then
                PID=$(systemctl show -p MainPID --value "tfgrid-ai-project@${PROJECT}.service")
                
                # Update state file with flock
                (
                    flock -x 200
                    CURRENT_STATE=$(cat "$STATE_FILE")
                    UPDATED_STATE=$(echo "$CURRENT_STATE" | jq \
                        --arg project "$PROJECT" \
                        --arg pid "$PID" \
                        --arg started "$(date -Iseconds)" \
                        '.[$project] = {"pid": $pid, "status": "running", "started_at": $started}')
                    echo "$UPDATED_STATE" > "$STATE_FILE"
                ) 200>"$LOCK_FILE"
                
                echo '{"status":"success","project":"'"$PROJECT"'","pid":'"$PID"'}'
            else
                echo '{"status":"error","message":"Service started but not active"}'
            fi
        else
            echo '{"status":"error","message":"Failed to start service"}'
        fi
        ;;
        
    stop)
        if [ -z "$PROJECT" ]; then
            echo '{"status":"error","message":"Missing project name"}'
            exit 0
        fi
        
        # Check if running
        if ! systemctl is-active --quiet "tfgrid-ai-project@${PROJECT}.service"; then
            echo '{"status":"error","message":"Project not running"}'
            exit 0
        fi
        
        if systemctl stop "tfgrid-ai-project@${PROJECT}.service" 2>/dev/null; then
            # Update state file
            (
                flock -x 200
                CURRENT_STATE=$(cat "$STATE_FILE")
                UPDATED_STATE=$(echo "$CURRENT_STATE" | jq --arg project "$PROJECT" 'del(.[$project])')
                echo "$UPDATED_STATE" > "$STATE_FILE"
            ) 200>"$LOCK_FILE"
            
            echo '{"status":"success","project":"'"$PROJECT"'"}'
        else
            echo '{"status":"error","message":"Failed to stop service"}'
        fi
        ;;
        
    status)
        if [ -z "$PROJECT" ]; then
            # Return status of all projects
            cat "$STATE_FILE"
        else
            # Return status of specific project
            STATUS=$(cat "$STATE_FILE" | jq --arg project "$PROJECT" '.[$project] // null')
            echo "$STATUS"
        fi
        ;;
        
    list)
        # List all running projects
        PROJECTS=$(systemctl list-units 'tfgrid-ai-project@*.service' --no-legend --no-pager 2>/dev/null | \
                   awk '{print $1}' | \
                   sed 's/tfgrid-ai-project@\(.*\)\.service/\1/' || echo "")
        
        if [ -z "$PROJECTS" ]; then
            echo '{"projects":[]}'
        else
            PROJECT_ARRAY=$(echo "$PROJECTS" | jq -R . | jq -s .)
            echo '{"projects":'"$PROJECT_ARRAY"'}'
        fi
        ;;
        
    *)
        echo '{"status":"error","message":"Unknown action: '"$ACTION"'"}'
        ;;
esac
