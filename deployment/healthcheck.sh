#!/usr/bin/env bash
# Health check script - Verify the deployment is working
# This runs after configuration to ensure everything is operational

set -e

echo "🏥 Running health checks for tfgrid-ai-agent..."

# Check if service is running
echo -n "🔍 Checking service status... "
if systemctl is-active --quiet tfgrid-ai-agent; then
    echo "✅ Service is running"
else
    echo "❌ Service is NOT running"
    systemctl status tfgrid-ai-agent
    exit 1
fi

# Check if qwen-cli is installed
echo -n "🔍 Checking qwen-cli... "
if command -v qwen &> /dev/null; then
    echo "✅ qwen-cli is installed ($(qwen --version 2>&1 | head -1 || echo 'installed'))"
else
    echo "❌ qwen-cli is NOT installed"
    exit 1
fi

# Check if Node.js is installed
echo -n "🔍 Checking Node.js... "
if command -v node &> /dev/null; then
    echo "✅ Node.js is installed ($(node --version))"
else
    echo "❌ Node.js is NOT installed"
    exit 1
fi

# Check workspace exists
echo -n "🔍 Checking workspace... "
if [ -d "/opt/ai-agent" ]; then
    echo "✅ Workspace exists"
else
    echo "❌ Workspace does NOT exist"
    exit 1
fi

# Check scripts are executable
echo -n "🔍 Checking scripts... "
if [ -x "/opt/ai-agent/scripts/agent-loop.sh" ]; then
    echo "✅ Scripts are executable"
else
    echo "❌ Scripts are NOT executable"
    exit 1
fi

# Check log directory
echo -n "🔍 Checking log directory... "
if [ -d "/var/log/ai-agent" ]; then
    echo "✅ Log directory exists"
else
    echo "❌ Log directory does NOT exist"
    exit 1
fi

echo ""
echo "✅ All health checks passed!"
echo "🎉 tfgrid-ai-agent is ready to use"
