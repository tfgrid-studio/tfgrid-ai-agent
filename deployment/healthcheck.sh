#!/usr/bin/env bash
# Health check script - Verify the deployment is working
# This runs after configuration to ensure everything is operational

set -e

echo "🏥 Running health checks for tfgrid-ai-agent..."

# Check if manager socket is active
echo -n "🔍 Checking manager socket... "
if systemctl is-active --quiet tfgrid-ai-manager.socket; then
    echo "✅ Manager socket is active"
else
    echo "❌ Manager socket is NOT active"
    systemctl status tfgrid-ai-manager.socket
    exit 1
fi

# Check if socket exists
echo -n "🔍 Checking socket... "
if [ -S /run/ai-agent.sock ]; then
    echo "✅ Socket exists"
else
    echo "❌ Socket does NOT exist"
    exit 1
fi

# Check if socket responds
echo -n "🔍 Checking socket communication... "
RESPONSE=$(echo '{"action":"list"}' | nc -U /run/ai-agent.sock 2>/dev/null || echo "")
if [ -n "$RESPONSE" ]; then
    echo "✅ Socket is responsive"
else
    echo "❌ Socket not responding"
    exit 1
fi

# Check nc and jq
echo -n "🔍 Checking nc (netcat)... "
if command -v nc &> /dev/null; then
    echo "✅ nc is installed"
else
    echo "❌ nc is NOT installed"
    exit 1
fi

echo -n "🔍 Checking jq... "
if command -v jq &> /dev/null; then
    echo "✅ jq is installed"
else
    echo "❌ jq is NOT installed"
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
