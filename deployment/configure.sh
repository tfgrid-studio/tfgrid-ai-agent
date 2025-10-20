#!/usr/bin/env bash
# Configure script - Set up the ai-agent systemd service template
# This runs after setup to configure the systemd service

set -e

echo "⚙️  Configuring tfgrid-ai-agent..."

# No state directory needed anymore (systemd manages everything)
echo "✅ Using systemd for project management"

# The tfgrid-ai-project@.service template was already installed by setup.sh
# Just verify it exists
if systemctl cat tfgrid-ai-project@.service &>/dev/null; then
    echo "✅ Project service template installed"
else
    echo "❌ Project service template not found"
    exit 1
fi

echo "✅ Configuration complete"
echo "ℹ️  Project template: tfgrid-ai-project@.service"
echo "ℹ️  Create projects with: tfgrid-compose create"
echo "ℹ️  Start projects with: tfgrid-compose run <project-name>"
