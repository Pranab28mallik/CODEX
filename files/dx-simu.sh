#!/data/data/com.termux/files/usr/bin/bash

# Set PATH to ensure script uses Termux's bin directory
export PATH="/data/data/com.termux/files/usr/bin:$PATH"

# Configuration Variables
CODEX_URL="https://codex-server-pied.vercel.app"
TERMUX_DIR="$HOME/.termux"
VERSION_FILE="$TERMUX_DIR/dx.txt"
ADS_FILE="$TERMUX_DIR/ads.txt"
TIMESTAMP_FILE="$TERMUX_DIR/.last_update_check"
CHECK_INTERVAL_SECONDS=300  # 5 minutes

# Create the Termux directory if it doesn't exist
mkdir -p "$TERMUX_DIR"

# Check if last update check was recent enough
if [[ -f "$TIMESTAMP_FILE" ]]; then
    # Get the last modification time of the timestamp file
    if command -v stat &>/dev/null; then
        # Compatible with GNU and BSD
        if stat -c %Y "$TIMESTAMP_FILE" &>/dev/null; then
            last_check=$(stat -c %Y "$TIMESTAMP_FILE")
        elif stat -f %m "$TIMESTAMP_FILE" &>/dev/null; then
            last_check=$(stat -f %m "$TIMESTAMP_FILE")
        else
            last_check=$(date +%s)
        fi
    else
        last_check=$(date +%s)
    fi

    now=$(date +%s)
    time_diff=$((now - last_check))

    # Exit if checked recently
    if (( time_diff < CHECK_INTERVAL_SECONDS )); then
        exit 0
    fi
fi

# Update the timestamp to current time
touch "$TIMESTAMP_FILE"

# Fetch version message from server
update_message=$(curl -fsS "$CODEX_URL/check_version" | jq -r '.[0].message // empty')

# Save the message or clear the version file
if [[ -n "$update_message" ]]; then
    echo "$update_message" > "$VERSION_FILE"
else
    echo "" > "$VERSION_FILE"
fi

# Fetch ads message from server
ads_output=$(curl -fsS "$CODEX_URL/ads" | jq -r '.[] | .message')

# Save the ads message or clear the ads file
if [[ -n "$ads_output" ]]; then
    echo "$ads_output" > "$ADS_FILE"
else
    echo "" > "$ADS_FILE"
fi

exit 0
