#!/bin/bash
# Socket client helper library
# Provides reusable function for communicating with daemon

SOCKET_PATH="/run/ai-agent.sock"

# Function to send command and get response
# Usage: send_daemon_command "action" ["project"]
send_daemon_command() {
    local action="$1"
    local project="${2:-}"
    
    # Build JSON request
    if [ -n "$project" ]; then
        REQUEST='{"action":"'"$action"'","project":"'"$project"'"}'
    else
        REQUEST='{"action":"'"$action"'"}'
    fi
    
    # Check if socket exists
    if [ ! -S "$SOCKET_PATH" ]; then
        echo '{"status":"error","message":"Daemon not running (socket not found)"}'
        return 1
    fi
    
    # Send to daemon and get response
    RESPONSE=$(echo "$REQUEST" | socat - UNIX-CONNECT:"$SOCKET_PATH" 2>/dev/null || echo '{"status":"error","message":"Failed to connect to daemon"}')
    echo "$RESPONSE"
}
