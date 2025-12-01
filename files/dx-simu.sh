#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# CODEX Background Updater & Cacher
# Purpose: Fetches server messages (updates/ads) and caches them locally.
# Designed to be run periodically (e.g., via Termux-API Cron or similar).
# =========================================================================

# --- CONFIGURATION ---
CODEX_URL="https://codex-server-pied.vercel.app"
TERMUX_DIR="$HOME/.termux"

# Cache Files
VERSION_FILE="$TERMUX_DIR/dx.txt"
ADS_FILE="$TERMUX_DIR/ads.txt"
TIMESTAMP_FILE="$TERMUX_DIR/.last_update_check"

# Check interval in seconds (5 minutes)
CHECK_INTERVAL_SECONDS=300

# Error output
ERR_LOG="$TERMUX_DIR/updater_error.log"

# --- CORE LOGIC ---

# 1. Ensure the Termux directory exists
mkdir -p "$TERMUX_DIR" 2>/dev/null

# 2. Check last update timestamp to throttle requests
if [[ -f "$TIMESTAMP_FILE" ]]; then
    
    # Use the portable approach for getting last modification time (seconds since epoch)
    local last_check
    last_check=$(stat -c %Y "$TIMESTAMP_FILE" 2>/dev/null || stat -f %m "$TIMESTAMP_FILE" 2>/dev/null)
    local now=$(date +%s)
    local time_diff=$((now - last_check))

    if (( time_diff < CHECK_INTERVAL_SECONDS )); then
        # Exit silently if the interval hasn't passed
        exit 0
    fi
fi

# Update the timestamp immediately before fetching data
touch "$TIMESTAMP_FILE"

# 3. Fetch Version/Update Message
local update_message
if ! update_message=$(curl -fsS "$CODEX_URL/check_version" 2>/dev/null | jq -r '.[0].message // empty'); then
    echo "$(date): Error fetching or parsing version data." >> "$ERR_LOG"
    # If fetch failed, we leave the old content and continue, but log the error.
    update_message="" 
fi

# Save the message to the version file
echo "$update_message" > "$VERSION_FILE"

# 4. Fetch Advertisements
local ads_output
if ! ads_output=$(curl -fsS "$CODEX_URL/ads" 2>/dev/null | jq -r '.[] | .message'); then
    echo "$(date): Error fetching or parsing ads data." >> "$ERR_LOG"
    # If fetch failed, we leave the old content and continue, but log the error.
    ads_output=""
fi

# Save ads to the ads file
echo "$ads_output" > "$ADS_FILE"

# 5. Clean exit
exit 0

