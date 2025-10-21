# TFGrid AI Agent

AI-powered coding agent with loop technique for safe AI coding environments.

## Overview

TFGrid AI Agent is a standalone application that provides an isolated, safe environment for AI-assisted coding. It uses the "loop technique" to enable AI agents to iteratively work on projects without risking your local development environment.

## Features

- 🤖 **AI-Powered Coding** - Uses qwen-cli for AI assistance
- 🔄 **Loop Technique** - Iterative AI coding with safety
- 🏝️ **Isolated Environment** - Runs on dedicated VM
- 📦 **Project Management** - Create, edit, and manage projects
- 🔒 **Safe** - No access to your local files
- ⚡ **Concurrent Projects** - Run multiple AI agents simultaneously

## Quick Start

### Deploy with TFGrid Compose

```bash
# Deploy the AI agent
tfgrid-compose up tfgrid-ai-agent

# Connect to the agent
tfgrid-compose ssh tfgrid-ai-agent

# Check logs
tfgrid-compose logs tfgrid-ai-agent

# Check status
tfgrid-compose status tfgrid-ai-agent
```

### Inside the Agent

Once connected, you can use the agent scripts:

```bash
# Create a new project
/opt/ai-agent/scripts/create-project.sh my-project

# Run the agent loop
/opt/ai-agent/scripts/agent-loop.sh

# List projects
/opt/ai-agent/scripts/list-projects.sh
```

## Structure

```
tfgrid-ai-agent/
├── tfgrid-compose.yaml      # Deployment manifest
├── src/                     # Application source
│   ├── scripts/             # Agent scripts
│   └── templates/           # Project templates
├── deployment/              # Deployment hooks
│   ├── setup.sh             # Install dependencies
│   ├── configure.sh         # Configure service
│   └── healthcheck.sh       # Verify deployment
├── patterns/                # Pattern-specific configs
└── docs/                    # Documentation
```

## Requirements

**Minimum:**
- 2 CPU cores
- 4 GB RAM
- 50 GB disk

**Recommended:**
- 4 CPU cores
- 8 GB RAM
- 100 GB disk

## Dependencies

The deployment automatically installs:
- Node.js (>=18.0.0)
- npm (>=9.0.0)
- qwen-cli (@qwen-code/qwen-code)
- git, curl, wget

## Configuration

### Environment Variables

**QWEN_API_KEY** (optional)
- Qwen API key for AI access
- Can be set after deployment

**PROJECT_WORKSPACE** (default: `/opt/ai-agent`)
- Agent workspace directory
- All projects stored here

## Patterns

### Supported Patterns

**single-vm** (Recommended)
- Single VM deployment
- Private access via Wireguard/Mycelium
- Best for development

**k3s** (Future)
- Kubernetes deployment
- For team environments

## Usage

### Creating Projects

```bash
# Create from template
/opt/ai-agent/scripts/create-project.sh my-web-app

# Edit existing project
/opt/ai-agent/scripts/edit-project.sh my-web-app

# List all projects
/opt/ai-agent/scripts/list-projects.sh

# Delete project
/opt/ai-agent/scripts/delete-project.sh my-web-app
```

### Running the Agent Loop

```bash
# Start the agent loop (interactive)
/opt/ai-agent/scripts/agent-loop.sh

# Advanced loop with more options
/opt/ai-agent/scripts/agent-loop-advanced.sh
```

### Project Workspace

All projects are stored in `/opt/ai-agent/projects/`:

```
/opt/ai-agent/
├── projects/
│   ├── my-web-app/
│   ├── my-api/
│   └── my-tool/
├── logs/
└── scripts/
```

## Logging

Logs are available via:

```bash
# Systemd logs
journalctl -u tfgrid-ai-agent -f

# Application logs
tail -f /var/log/ai-agent/output.log
tail -f /var/log/ai-agent/error.log
```

## Service Management

The agent runs as a systemd service:

```bash
# Check status
systemctl status tfgrid-ai-agent

# Start/stop
systemctl start tfgrid-ai-agent
systemctl stop tfgrid-ai-agent

# Restart
systemctl restart tfgrid-ai-agent

# View logs
journalctl -u tfgrid-ai-agent -f
```

## Troubleshooting

### Service not running

```bash
# Check status
systemctl status tfgrid-ai-agent

# View logs
journalctl -u tfgrid-ai-agent -n 50

# Restart
systemctl restart tfgrid-ai-agent
```

### qwen-cli issues

```bash
# Check installation
qwen --version

# Reinstall
npm install -g @qwen-code/qwen-code
```

### Permission issues

```bash
# Fix workspace permissions
chown -R root:root /opt/ai-agent
chmod -R 755 /opt/ai-agent/scripts
```

## Development

### Local Development

You can run the agent locally without TFGrid:

```bash
# Clone the repo
git clone https://github.com/tfgrid-studio/tfgrid-ai-agent
cd tfgrid-ai-agent

# Run setup manually
sudo ./deployment/setup.sh
sudo ./deployment/configure.sh
./deployment/healthcheck.sh
```

### Contributing

Contributions welcome! Please:
1. Fork the repo
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## Security

- Agent runs in isolated VM
- No access to local files
- All code execution in safe environment
- Review all AI-generated code before use

## License

Apache 2.0

## Links

- **GitHub:** [tfgrid-studio/tfgrid-ai-agent](https://github.com/tfgrid-studio/tfgrid-ai-agent)
- **Documentation:** [docs.tfgrid.studio](https://docs.tfgrid.studio)
- **TFGrid Studio:** [github.com/tfgrid-studio](https://github.com/tfgrid-studio)

---

**Part of:** [TFGrid Studio](https://github.com/tfgrid-studio)  
**Status:** ✅ Production Ready  
**Version:** 0.3.0
**Concurrent Projects:** ✅ Multiple projects supported
**Compatible with:** tfgrid-compose v0.11.0+ (all patterns)