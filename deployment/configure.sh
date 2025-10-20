#!/usr/bin/env bash
# Configure script - Set up the ai-agent service
# This runs after setup to configure the systemd service

set -e

echo "⚙️  Configuring tfgrid-ai-agent..."

# Create state directory for manager daemon
echo "📁 Creating state directory..."
mkdir -p /var/lib/ai-agent
chmod 755 /var/lib/ai-agent
echo '{}' > /var/lib/ai-agent/projects.json

# Install manager socket + service (systemd socket activation)
echo "📝 Installing manager socket + service..."
cp /tmp/app-source/systemd/tfgrid-ai-manager.socket /etc/systemd/system/
cp /tmp/app-source/systemd/tfgrid-ai-manager@.service /etc/systemd/system/

# Keep old single service for backward compatibility (inactive)
cat > /etc/systemd/system/tfgrid-ai-agent.service << 'EOF'
[Unit]
Description=TFGrid AI Agent Service (Legacy - Use Manager)
After=network.target

[Service]
Type=simple
User=developer
WorkingDirectory=/home/developer
ExecStart=/bin/bash -c "echo 'Use tfgrid-compose commands to manage projects'"
Restart=no

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd to recognize new service files
echo "🔄 Reloading systemd daemon..."
systemctl daemon-reload

# Enable and start socket listener
echo "🚀 Starting AI Agent Manager socket..."
systemctl enable tfgrid-ai-manager.socket
systemctl start tfgrid-ai-manager.socket

# Wait for socket to be ready
sleep 1

# Verify socket is listening
if systemctl is-active --quiet tfgrid-ai-manager.socket; then
    echo "✅ Manager socket started successfully"
    if [ -S /var/run/ai-agent.sock ]; then
        echo "✅ Socket listening: /var/run/ai-agent.sock"
    else
        echo "⚠️  Socket not found"
        exit 1
    fi
else
    echo "❌ Failed to start manager socket"
    journalctl -u tfgrid-ai-manager.socket -n 20 --no-pager
    exit 1
fi

echo "✅ Configuration complete"
echo "ℹ️  Manager socket: tfgrid-ai-manager.socket"
echo "ℹ️  Manager handler: tfgrid-ai-manager@.service"
echo "ℹ️  Project template: tfgrid-ai-project@.service"
