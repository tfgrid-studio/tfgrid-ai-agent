#!/bin/bash
# Authenticate with Qwen using OAuth
# Stores credentials in /home/developer/.qwen/

echo "🔐 Qwen Authentication"
echo "====================="
echo ""
echo "This will start the interactive Qwen CLI."
echo "You'll be asked: 'How would you like to authenticate?'"
echo ""
echo "Steps:"
echo "  1. Choose option 1 (OAuth)"
echo "  2. Copy the authorization URL that appears"
echo "  3. Open it in your LOCAL web browser"
echo "  4. Sign in with your Google account"
echo "  5. Come back and press ESC when authenticated"
echo ""
echo "Press Ctrl+C to cancel, or press Enter to continue..."
read

# Run qwen interactive CLI as developer user
# This will prompt for authentication if not already authenticated
exec su - developer -c 'qwen'
