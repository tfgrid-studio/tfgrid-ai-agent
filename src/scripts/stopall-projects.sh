#!/bin/bash
# stopall-projects.sh - Stop all running AI agent loops
# This stops all running agent loops across all projects in the workspace

set -e

echo " Stopping All AI Agent Loops"
echo "=============================="
echo ""

# Determine workspace base directory
WORKSPACE_BASE="${PROJECT_WORKSPACE:-/home/developer/code}"

# Collect all running projects
running_projects=()
running_pids=()

# Search across all git sources
for project_dir in "$WORKSPACE_BASE"/*/*/.agent "$WORKSPACE_BASE"/*/*/*/.agent; do
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
        running_projects+=("$project_name")
        running_pids+=("$PROJECT_PID")
    fi
done

# Check if any projects are running
if [ ${#running_projects[@]} -eq 0 ]; then
    echo "✅ No running projects found"
    exit 0
fi

# Display running projects
echo "Found ${#running_projects[@]} running project(s):"
echo ""
for i in "${!running_projects[@]}"; do
    echo "  - ${running_projects[$i]} (PID: ${running_pids[$i]})"
done
echo ""

# Confirm
read -p "Stop all projects? (y/N): " confirm
if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "❌ Cancelled"
    exit 0
fi

echo ""
echo "🛑 Stopping all projects..."
echo ""

# Stop each project
for project_name in "${running_projects[@]}"; do
    echo "  Stopping: $project_name"
    "$(dirname "$0")/stop-project.sh" "$project_name" 2>&1 | sed 's/^/    /'
done

echo ""
echo "✅ All projects stopped successfully"
