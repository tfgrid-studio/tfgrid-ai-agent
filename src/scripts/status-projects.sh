#!/bin/bash
# status-projects.sh - Show status of all AI agent projects
# Part of the AI-Agent framework

set -e

echo "AI Agent Projects Status"
echo "========================="
echo ""

# Find all projects with .agent directory
found_projects=false

for project_dir in ../*/.agent; do
    if [ ! -d "$project_dir" ]; then
        continue
    fi
    
    project_path=$(dirname "$project_dir")
    project_name=$(basename "$project_path")
    
    # Skip the ai-agent directory itself
    if [ "$project_name" = "ai-agent" ]; then
        continue
    fi
    
    found_projects=true
    
    # Get project info
    cd "$project_path"
    
    # Check if running - look for the project path in process args
    PROJECT_PID=$(pgrep -f "agent-loop.sh.*$project_path" 2>/dev/null || echo "")
    
    # Get version and time constraint
    if [ -f ".agent/time_log.txt" ]; then
        VERSION=$(grep "Project Version:" .agent/time_log.txt 2>/dev/null | cut -d':' -f2 | tr -d ' ')
        [ -z "$VERSION" ] && VERSION="1"
        TIME_CONSTRAINT=$(grep "Time Constraint:" .agent/time_log.txt 2>/dev/null | cut -d':' -f2- | xargs)
        [ -z "$TIME_CONSTRAINT" ] && TIME_CONSTRAINT="indefinite"
        START_TIME=$(grep "Project Start Time:" .agent/time_log.txt 2>/dev/null | cut -d':' -f2- | xargs)
        [ -z "$START_TIME" ] && START_TIME="unknown"
    else
        VERSION="1"
        TIME_CONSTRAINT="indefinite"
        START_TIME="unknown"
    fi
    
    # Get last commit
    LAST_COMMIT=$(git log -1 --format="%cr" 2>/dev/null || echo "no commits")
    
    # Status indicator
    if [ -n "$PROJECT_PID" ]; then
        STATUS="🟢 Running (PID: $PROJECT_PID)"
    else
        STATUS="⭕ Stopped"
    fi
    
    # Print project info
    echo "📁 $project_name"
    echo "   Status: $STATUS"
    echo "   Version: $VERSION"
    echo "   Time constraint: $TIME_CONSTRAINT"
    echo "   Started: $START_TIME"
    echo "   Last commit: $LAST_COMMIT"
    echo ""
    
    cd - > /dev/null
done

if [ "$found_projects" = false ]; then
    echo "No projects found."
    echo ""
    echo "Create one with: make create"
fi
