#!/bin/bash
# Wrapper for socat EXEC to properly invoke handler
exec stdbuf -oL /opt/ai-agent/scripts/handle-command.sh
