#!/usr/bin/env bash
# Setup script - Install dependencies and prepare the environment
# This runs on the VM during deployment

set -e

echo "🚀 Setting up tfgrid-ai-agent..."

# Install Node.js
echo "📦 Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# Install qwen-cli
echo "📦 Installing qwen-cli..."
npm install -g @qwen-code/qwen-code

# Create workspace directories
echo "📁 Creating workspace..."
mkdir -p /opt/ai-agent/{projects,logs}

# Copy agent scripts
echo "📋 Copying agent scripts..."
cp -r /tmp/app-source/scripts /opt/ai-agent/
cp -r /tmp/app-source/templates /opt/ai-agent/

# Make scripts executable
chmod +x /opt/ai-agent/scripts/*.sh

# Create log directory
mkdir -p /var/log/ai-agent

echo "✅ Setup complete"
