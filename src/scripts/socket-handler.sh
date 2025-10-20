#!/bin/bash
# Socket handler wrapper - prevents SIGPIPE issues
# This wrapper ensures output completes before connection closes

# Trap SIGPIPE to prevent script exit
trap '' PIPE

# Read stdin to temp file to ensure we read everything before input closes
INPUT=$(cat)

# Call actual handler with input
OUTPUT=$(echo "$INPUT" | /opt/ai-agent/scripts/handle-command.sh 2>&1)

# Write output with explicit error handling
if [ -n "$OUTPUT" ]; then
    # Try to write output, ignore SIGPIPE
    echo "$OUTPUT" 2>/dev/null || true
fi

# Give systemd time to read output buffer before we exit
sleep 0.1

exit 0
