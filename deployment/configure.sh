#!/usr/bin/env bash
# Configure script - Set up the ai-agent service
# This runs after setup to configure the systemd service

set -e

echo "⚙️  Configuring tfgrid-ai-agent..."

# Create systemd service (disabled by default - projects run on-demand)
echo "📝 Creating systemd service..."
cat > /etc/systemd/system/tfgrid-ai-agent.service << 'EOF'
[Unit]
Description=TFGrid AI Agent Service
After=network.target

[Service]
Type=simple
User=developer
WorkingDirectory=/home/developer
ExecStart=/bin/bash -c "echo 'AI Agent service started - use tfgrid-compose commands to manage projects'"
Restart=no
StandardOutput=append:/var/log/ai-agent/output.log
StandardError=append:/var/log/ai-agent/error.log

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd
echo "🔄 Reloading systemd..."
systemctl daemon-reload

# Enable and start service
echo "▶️  Starting service..."
systemctl enable tfgrid-ai-agent
systemctl start tfgrid-ai-agent

echo "✅ Configuration complete"
