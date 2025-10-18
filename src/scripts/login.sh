#!/bin/bash
# Authenticate with Qwen using OAuth
# Stores credentials in /home/developer/.qwen/

echo "🔐 Qwen Authentication"
echo "====================="
echo ""
echo "This will start the interactive OAuth flow."
echo "You'll need to:"
echo "  1. Copy the authorization URL that appears"
echo "  2. Open it in your LOCAL web browser"
echo "  3. Sign in with your Google account"
echo "  4. Come back and press ESC when done"
echo ""
echo "Press Ctrl+C to cancel, or press Enter to continue..."
read

# Run qwen login as developer user
exec su - developer -c 'qwen login'
