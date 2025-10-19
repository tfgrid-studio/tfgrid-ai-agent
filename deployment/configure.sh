#!/usr/bin/env bash
# Configure script - Set up the ai-agent service
# This runs after setup to configure the systemd service

set -e

echo "⚙️  Configuring tfgrid-ai-agent..."

# Create systemd service file (but don't touch systemd during deployment)
echo "📝 Creating systemd service file..."
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

# Mark that systemd needs to be reloaded on first use
# We can't run daemon-reload here because it might disrupt the Ansible SSH session
touch /tmp/.tfgrid-systemd-needs-reload

# Don't enable/start the service automatically
# Service will be started on-demand when user runs commands

echo "✅ Configuration complete"
echo "ℹ️  Systemd service configured (daemon-reload will happen on first project start)"
