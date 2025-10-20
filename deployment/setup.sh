#!/usr/bin/env bash
# Setup script - Install dependencies and prepare the environment
# This runs on the VM during deployment

set -e

echo "🚀 Setting up tfgrid-ai-agent..."

# Install Node.js
echo "📦 Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs

# Install expect for OAuth automation
echo "📦 Installing expect..."
apt-get install -y expect

# Install jq for JSON parsing
echo "📦 Installing jq..."
apt-get install -y jq

# Install qwen-cli
echo "📦 Installing qwen-cli..."
npm install -g @qwen-code/qwen-code

# Create developer user if it doesn't exist
echo "👤 Creating developer user..."
if ! id -u developer >/dev/null 2>&1; then
    useradd -m -s /bin/bash developer
    echo "✅ Created developer user"
else
    echo "ℹ️  Developer user already exists"
fi

# Add developer to sudo group (optional, for admin tasks)
usermod -aG sudo developer 2>/dev/null || true

# Configure git identity from tfgrid-compose credentials
echo "🔧 Configuring git identity..."
if [ -n "$TFGRID_GIT_NAME" ] && [ -n "$TFGRID_GIT_EMAIL" ]; then
    echo "  Using credentials from tfgrid-compose login"
    GIT_NAME="$TFGRID_GIT_NAME"
    GIT_EMAIL="$TFGRID_GIT_EMAIL"
    echo "  Name:  $GIT_NAME"
    echo "  Email: $GIT_EMAIL"
else
    echo "  No git credentials provided - using defaults"
    echo "  (Run 'tfgrid-compose login' to add your git identity)"
    GIT_NAME="AI Agent"
    GIT_EMAIL="agent@localhost"
fi

# Create workspace directories as developer
echo "📁 Creating workspace..."
su - developer <<EOF
mkdir -p ~/code/tfgrid-ai-agent-projects
mkdir -p ~/code/github.com
mkdir -p ~/code/git.ourworld.tf
mkdir -p ~/code/gitlab.com
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Configure git with user's identity
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
git config --global init.defaultBranch main

echo "✅ Workspace created at ~/code"
echo "✅ Git configured: $GIT_NAME <$GIT_EMAIL>"
EOF

# Create agent scripts directory (system-level for management scripts)
echo "📁 Creating agent scripts directory..."
mkdir -p /opt/ai-agent/{scripts,templates,logs}

# Copy agent scripts
echo "📋 Copying agent scripts..."
cp -r /tmp/app-source/scripts /opt/ai-agent/
cp -r /tmp/app-source/templates /opt/ai-agent/

# Make scripts executable
chmod +x /opt/ai-agent/scripts/*.sh

# Set proper ownership
chown -R developer:developer /opt/ai-agent
chmod -R 755 /opt/ai-agent/scripts

# Create log directory
mkdir -p /var/log/ai-agent
chown developer:developer /var/log/ai-agent

# Fix workspace permissions and copy qwen credentials
echo "🔧 Setting up workspace permissions..."
chown -R developer:developer /home/developer/code
cp -r /home/developer/.qwen /root/ 2>/dev/null || echo "ℹ️  Qwen credentials not yet available (will be set up during login)"

# Install systemd template service for per-project management
echo "🔧 Installing systemd template service..."
cp /tmp/app-source/systemd/tfgrid-ai-project@.service /etc/systemd/system/
systemctl daemon-reload

# Disable old single service if it exists
if systemctl list-unit-files | grep -q "^tfgrid-ai-agent.service"; then
    echo "🔧 Disabling old single-service architecture..."
    systemctl stop tfgrid-ai-agent.service 2>/dev/null || true
    systemctl disable tfgrid-ai-agent.service 2>/dev/null || true
fi

echo "✅ Setup complete"
echo "👤 Developer user ready: /home/developer"
echo "📁 Workspace: /home/developer/code"
echo "🔧 Systemd template: tfgrid-ai-project@.service (per-project instances)"
