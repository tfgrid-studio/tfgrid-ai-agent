#!/bin/bash
# Socket handler wrapper - prevents SIGPIPE issues

# Trap SIGPIPE to prevent script exit on broken pipe
trap '' PIPE

# Pipe stdin directly to handler, then to stdout
# Using exec to replace this process, avoiding double-buffering
exec /opt/ai-agent/scripts/handle-command.sh
