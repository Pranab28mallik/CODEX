#!/data/data/com.termux/files/usr/bin/bash

# --- Configuration ---
# Termux path setup is usually done automatically, but we keep it for strictness.
export PATH="/data/data/com.termux/files/usr/bin:$PATH"

# Base URL for the remote server
CODEX_URL="https://codex-server-pied.vercel.app"

# Directory and file paths
TERMUX_DIR="$HOME/.termux"
VERSION_FILE="$TERMUX_DIR/dx.txt"
ADS_FILE="$TERMUX_DIR/ads.txt"
LOG_FILE="$TERMUX_DIR/update_check.log"
TIMESTAMP_FILE="$TERMUX_DIR/.last_update_check"

# Time interval for checking updates (in seconds, 5 minutes)
CHECK_INTERVAL_SECONDS=300

# Required command-line tools
REQUIRED_TOOLS=("curl" "jq" "date" "stat")

# --- Utility Functions ---

# Function to log messages
log() {
    local severity="$1" # INFO, WARN, ERROR
    local message="$2"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] [$severity] $message" >> "$LOG_FILE"
}

# Function to check for required dependencies
check_dependencies() {
    log "INFO" "Checking required dependencies..."
    for tool in "${REQUIRED_TOOLS[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            log "ERROR" "Dependency '$tool' not found. Please install it (e.g., 'pkg install $tool')."
            echo "Error: Required tool '$tool' not found. Exiting." >&2
            exit 1
        fi
    done
    log "INFO" "All dependencies found."
}

# Function to check if the time interval has elapsed
is_check_due() {
    mkdir -p "$TERMUX_DIR"
    
    # Check if the timestamp file exists and is readable
    if [[ -f "$TIMESTAMP_FILE" ]]; then
        # Use a robust way to get last modification time (handling both GNU stat and BSD stat on Termux)
        local last_check=$(stat -c %Y "$TIMESTAMP_FILE" 2>/dev/null || stat -f %m "$TIMESTAMP_FILE" 2>/dev/null)
        local now=$(date +%s)
        
        if [[ -z "$last_check" ]]; then
            log "WARN" "Could not determine last check time from timestamp file. Proceeding with check."
            return 0 # Time check failed, proceed anyway
        fi

        local time_diff=$((now - last_check))

        if (( time_diff < CHECK_INTERVAL_SECONDS )); then
            log "INFO" "Check interval ($CHECK_INTERVAL_SECONDS s) not elapsed. Skipping check (Time elapsed: $time_diff s)."
            return 1 # Not due
        fi
        log "INFO" "Check due. Time elapsed: $time_diff s."
        return 0 # Due
    else
        log "INFO" "Timestamp file not found. Performing initial check."
        return 0 # Due (initial run)
    fi
}

# Function to fetch and update version message
fetch_and_update_version() {
    log "INFO" "Attempting to fetch version message from $CODEX_URL/check_version..."
    local temp_version_file
    
    # Use mktemp for atomic file writing
    temp_version_file=$(mktemp)

    if ! curl -fsS "$CODEX_URL/check_version" | jq -r '.[0].message // empty' > "$temp_version_file"; then
        log "ERROR" "Failed to fetch or parse version data. curl/jq error code: $?"
        rm -f "$temp_version_file"
        return 1
    fi

    # Check if the extracted content is non-empty before updating
    if [[ -s "$temp_version_file" ]]; then
        mv "$temp_version_file" "$VERSION_FILE"
        log "INFO" "Successfully updated version message in $VERSION_FILE."
    else
        echo "" > "$VERSION_FILE"
        log "WARN" "Fetched version message was empty. Cleared $VERSION_FILE."
    fi
    
    rm -f "$temp_version_file" 2>/dev/null
    return 0
}

# Function to fetch and update advertisements
fetch_and_update_ads() {
    log "INFO" "Attempting to fetch ads from $CODEX_URL/ads..."
    local temp_ads_file
    
    # Use mktemp for atomic file writing
    temp_ads_file=$(mktemp)

    # Use printf for better handling of multi-line output from jq
    if ! curl -fsS "$CODEX_URL/ads" | jq -r '.[] | .message' | sed -E '/^\s*$/d' > "$temp_ads_file"; then
        log "ERROR" "Failed to fetch or parse ads data. curl/jq error code: $?"
        rm -f "$temp_ads_file"
        return 1
    fi

    # Check if the extracted content is non-empty before updating
    if [[ -s "$temp_ads_file" ]]; then
        mv "$temp_ads_file" "$ADS_FILE"
        log "INFO" "Successfully updated ads message in $ADS_FILE."
    else
        echo "" > "$ADS_FILE"
        log "INFO" "Fetched ads message was empty or not applicable. Cleared $ADS_FILE."
    fi

    rm -f "$temp_ads_file" 2>/dev/null
    return 0
}

# --- Main Execution ---

main() {
    # 1. Dependency Check
    check_dependencies
    
    # 2. Check if the run is due
    if ! is_check_due; then
        exit 0 # Exit quietly if not due
    fi
    
    log "INFO" "Starting Termux update and ads check."
    
    # 3. Perform file checks and updates
    
    # Create the timestamp file immediately before starting the check cycle
    # This prevents parallel execution even if the script fails later
    touch "$TIMESTAMP_FILE"
    
    # Run fetch operations
    fetch_and_update_version
    fetch_and_update_ads
    
    log "INFO" "Check cycle completed."
    exit 0
}

# Execute the main function
main

