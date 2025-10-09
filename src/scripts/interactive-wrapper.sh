#!/bin/bash
# interactive-wrapper.sh - Provides interactive project selection for commands
# Part of the AI-Agent framework

set -e

COMMAND="$1"
PROJECT_NAME="$2"

# If PROJECT_NAME is provided, call script directly
if [ -n "$PROJECT_NAME" ]; then
    case "$COMMAND" in
        run)
            exec "$(dirname "$0")/run-project.sh" "$PROJECT_NAME"
            ;;
        stop)
            exec "$(dirname "$0")/stop-project.sh" "$PROJECT_NAME"
            ;;
        restart)
            exec "$(dirname "$0")/restart-project.sh" "$PROJECT_NAME"
            ;;
        monitor)
            exec "$(dirname "$0")/monitor-project.sh" "$PROJECT_NAME"
            ;;
        logs)
            exec "$(dirname "$0")/logs-project.sh" "$PROJECT_NAME"
            ;;
        summary)
            exec "$(dirname "$0")/summary-project.sh" "$PROJECT_NAME"
            ;;
        edit)
            exec "$(dirname "$0")/edit-project.sh" "$PROJECT_NAME"
            ;;
        remove)
            exec "$(dirname "$0")/remove-project.sh" "$PROJECT_NAME"
            ;;
        *)
            echo "❌ Unknown command: $COMMAND"
            exit 1
            ;;
    esac
fi

# No PROJECT_NAME provided - show interactive menu
echo "AI Agent Projects:"
echo ""

# Collect projects into array
projects=()
statuses=()

for project_dir in ../*/.agent; do
    if [ ! -d "$project_dir" ]; then
        continue
    fi
    
    project_path=$(dirname "$project_dir")
    project_name=$(basename "$project_path")
    
    # Skip ai-agent directory
    if [ "$project_name" = "ai-agent" ]; then
        continue
    fi
    
    # Check if running
    PROJECT_PID=$(pgrep -f "agent-loop.sh.*$project_name" 2>/dev/null || echo "")
    
    if [ -n "$PROJECT_PID" ]; then
        status="🟢 Running"
    else
        status="⭕ Stopped"
    fi
    
    projects+=("$project_name")
    statuses+=("$status")
done

# Check if any projects found
if [ ${#projects[@]} -eq 0 ]; then
    echo "No projects found."
    echo ""
    echo "Create one with: make create"
    exit 1
fi

# Display numbered list
for i in "${!projects[@]}"; do
    num=$((i + 1))
    echo "$num) ${projects[$i]} (${statuses[$i]})"
done

echo ""
read -p "Select project (1-${#projects[@]}): " selection

# Validate selection
if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt ${#projects[@]} ]; then
    echo "❌ Invalid selection"
    exit 1
fi

# Get selected project (adjust for 0-based array)
SELECTED_PROJECT="${projects[$((selection - 1))]}"

echo ""

# Call appropriate script with selected project
case "$COMMAND" in
    run)
        echo "🚀 Starting $SELECTED_PROJECT..."
        exec "$(dirname "$0")/run-project.sh" "$SELECTED_PROJECT"
        ;;
    stop)
        echo "🛑 Stopping $SELECTED_PROJECT..."
        exec "$(dirname "$0")/stop-project.sh" "$SELECTED_PROJECT"
        ;;
    restart)
        echo "🔄 Restarting $SELECTED_PROJECT..."
        exec "$(dirname "$0")/restart-project.sh" "$SELECTED_PROJECT"
        ;;
    monitor)
        echo "📊 Monitoring $SELECTED_PROJECT..."
        exec "$(dirname "$0")/monitor-project.sh" "$SELECTED_PROJECT"
        ;;
    logs)
        echo "📋 Viewing logs for $SELECTED_PROJECT..."
        exec "$(dirname "$0")/logs-project.sh" "$SELECTED_PROJECT"
        ;;
    summary)
        echo "📊 Generating summary for $SELECTED_PROJECT..."
        exec "$(dirname "$0")/summary-project.sh" "$SELECTED_PROJECT"
        ;;
    edit)
        echo "🔧 Editing $SELECTED_PROJECT..."
        exec "$(dirname "$0")/edit-project.sh" "$SELECTED_PROJECT"
        ;;
    remove)
        echo "🗑️ Removing $SELECTED_PROJECT..."
        exec "$(dirname "$0")/remove-project.sh" "$SELECTED_PROJECT"
        ;;
    *)
        echo "❌ Unknown command: $COMMAND"
        exit 1
        ;;
esac
