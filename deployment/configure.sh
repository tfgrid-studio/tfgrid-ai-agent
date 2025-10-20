#!/usr/bin/env bash
# Configure script - Set up the ai-agent service
# This runs after setup to configure the systemd service

set -e

echo "⚙️  Configuring tfgrid-ai-agent..."

# Create state directory for manager daemon
echo "📁 Creating state directory..."
mkdir -p /var/lib/ai-agent
chmod 755 /var/lib/ai-agent

# Install manager daemon systemd service
echo "📝 Installing manager daemon service..."
cp /tmp/app-source/systemd/tfgrid-ai-manager.service /etc/systemd/system/

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

# Enable and start manager daemon
echo "🚀 Starting AI Agent Manager daemon..."
systemctl enable tfgrid-ai-manager.service
systemctl start tfgrid-ai-manager.service

# Wait for socket to be ready
sleep 2

# Verify daemon is running
if systemctl is-active --quiet tfgrid-ai-manager.service; then
    echo "✅ Manager daemon started successfully"
    if [ -S /var/run/ai-agent.sock ]; then
        echo "✅ Socket created: /var/run/ai-agent.sock"
    else
        echo "⚠️  Socket not found (daemon may still be initializing)"
    fi
else
    echo "❌ Failed to start manager daemon"
    journalctl -u tfgrid-ai-manager.service -n 20 --no-pager
    exit 1
fi

echo "✅ Configuration complete"
echo "ℹ️  Manager daemon: tfgrid-ai-manager.service"
echo "ℹ️  Project template: tfgrid-ai-project@.service"
