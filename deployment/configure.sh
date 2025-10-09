#!/usr/bin/env bash
# Configure script - Set up the ai-agent service
# This runs after setup to configure the systemd service

set -e

echo "⚙️  Configuring tfgrid-ai-agent..."

# Create systemd service
echo "📝 Creating systemd service..."
cat > /etc/systemd/system/tfgrid-ai-agent.service << 'EOF'
[Unit]
Description=TFGrid AI Agent Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/ai-agent
ExecStart=/opt/ai-agent/scripts/agent-loop.sh
Restart=on-failure
RestartSec=10
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
