#!/usr/bin/env bash
# Setup script - Install dependencies and prepare the environment
# This runs on the VM during deployment

set -e

echo "🚀 Setting up tfgrid-ai-agent..."

# Install Node.js
echo "📦 Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# Install expect for OAuth automation
echo "📦 Installing expect..."
apt-get install -y expect

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

# Create workspace directories as developer
echo "📁 Creating workspace..."
su - developer <<'EOF'
mkdir -p ~/code/tfgrid-ai-agent-projects
mkdir -p ~/code/github.com
mkdir -p ~/code/git.ourworld.tf
mkdir -p ~/code/gitlab.com
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Configure git (will be overridden by user config if they set it)
git config --global user.name "AI Agent"
git config --global user.email "agent@localhost"
git config --global init.defaultBranch main

echo "✅ Workspace created at ~/code"
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

echo "✅ Setup complete"
echo "👤 Developer user ready: /home/developer"
echo "📁 Workspace: /home/developer/code"
