#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# Script: CODEX Advanced Anonymous Chat Tool
# Author: DARK-X (Original Script)
# Modified: Gemini AI (For better UX, robustness, and structure)
# Purpose: Interactive Termux client for an anonymous chat API.
# Dependencies: curl, jq (installed if not present)
# =========================================================================

# --- 1. CONFIGURATION AND STYLES ---

# Termux Paths and API URL
API_URL="https://codex-chat-hew1.onrender.com"
USERNAME_DIR="$HOME/.CODEX"
USERNAME_FILE="$USERNAME_DIR/usernames.txt"

# Colors and Styling
R='\033[1;91m' # Red (Error/Warning)
P='\033[1;95m' # Purple
Y='\033[1;93m' # Yellow
G='\033[1;92m' # Green (Success)
N='\033[0m'    # Reset
B='\033[1;94m' # Blue
C='\033[1;96m' # Cyan (Info)

# Symbols
SYMBOL_INFO="${C}[${N}i${C}]${G}"
SYMBOL_WARN="${Y}[${N}!${Y}]${R}"
SYMBOL_ERR="${R}[${N}✗${R}]${R}"
SYMBOL_ARROW="${G}[${N}»${G}]${C}"
SYMBOL_CHAT="${G}[${N}</>${G}]${C}"
SYMBOL_USER="${Y}[${N}@${Y}]${C}"

# Random choice for exit animation (for variety)
RANDOM_EXIT_STYLE=$(( RANDOM % 2 ))

# Ensure JQ is installed for JSON parsing
install_jq() {
    if ! command -v jq &> /dev/null; then
        echo -e "${SYMBOL_INFO} ${C}Installing 'jq' for JSON parsing...${N}"
        pkg install jq -y &> /dev/null
        if [ $? -ne 0 ]; then
             echo -e "${SYMBOL_ERR} ${R}Failed to install 'jq'. JSON parsing may fail.${N}"
        fi
    fi
}

# --- 2. CORE UTILITY FUNCTIONS ---

# Loading animation (Slightly enhanced)
loading_animation() {
    local delay=0.1
    for i in 1 2 3; do
        clear
        case $i in
            1) echo -e " ${R}●${N}";;
            2) echo -e " ${R}●${Y}●${N}";;
            3) echo -e " ${R}●${Y}●${B}●${N}";;
        esac
        sleep $delay
    done
}

# Internet connectivity check (Robust and user-friendly)
check_internet() {
    clear
    echo -e "\n               ${G}╔═══════════════╗"
    echo -e "               ${G}║ ${SYMBOL_CHAT} ${C}DARK-X${G}   ║"
    echo -e "               ${G}╚═══════════════╝"
    echo -e "  ${G}╔════════════════════════════════════════════╗"
    echo -e "  ${G}║  ${SYMBOL_INFO} ${Y}Checking Your Internet Connection...${G} ║"
    echo -e "  ${G}╚════════════════════════════════════════════╝${N}"
    
    local attempts=0
    local max_attempts=10
    
    while true; do
        curl --silent --head --fail https://google.com > /dev/null
        if [ "$?" -eq 0 ]; then
            echo -e "\n              ${G}╔══════════════════╗"
            echo -e "              ${G}║${SYMBOL_INFO} ${G}Internet UP ${G}║"
            echo -e "              ${G}╚══════════════════╝${N}"
            sleep 1
            break
        else
            if [ $attempts -ge $max_attempts ]; then
                 clear
                 echo -e "\n ${SYMBOL_ERR} ${R}Failed to connect after $max_attempts attempts.${N}"
                 echo -e " ${SYMBOL_INFO} ${C}Please check your connection and restart.${N}"
                 exit 1
            fi
            echo -e "\n              ${G}╔══════════════════╗"
            echo -e "              ${G}║${SYMBOL_ERR} ${R}No Internet ${G}║"
            echo -e "              ${G}╚══════════════════╝${N}"
            attempts=$((attempts + 1))
            sleep 3
        fi
    done
    clear
}

# Exit Animation 1 (Cat style - 'broken')
broken_exit() {
    local frames=(
        "=( ´ ${G}•⁠${P}ω${G}• ⁠${C})=   ˖<💌>."
        "=( ´ ${G}•⁠${P}ω${G}• ⁠${C})=   𖥔˖<💘>.𖥔"
        "=( ´ ${G}•⁠${P}ω${G}• ⁠${C})=   .𖥔 ˖<💘>.𖥔 ݁"
        "=( ´ ${G}•⁠${P}ω${G}• ⁠${C})=   𖥔 ݁ ˖<💛>.𖥔 ݁ "
        "=( ´ ${G}•⁠${P}ω${G}• ⁠${C})=   .𖥔 ݁ ˖<💗>.𖥔 ݁ ˖"
        "=( ´ ${G}•⁠${P}ω${G}• ⁠${C})=   ₊ଳ ‧₊˚ ⋅.𖥔 ݁ ˖<💔>.𖥔 ݁ ˖⋅˚₊‧ ଳ₊"
    )
    for frame in "${frames[@]}"; do
        clear
        echo -e "${C}\n        _(\___/)\n      ${frame}\n      // ͡     )︵)\n     (⁠人_____づ_づ"
        sleep 0.4
    done
    echo -e "\n ${SYMBOL_CHAT} ${G}Goodbye! ${Y}(${C}-${R}.${C}-${Y})${C}Zzz・・・・𑁍ࠬܓ${N}\n"
    exit 0
}

# Exit Animation 2 (Wave style - 'goodbye')
waving_exit() {
    local frames=(
        "╱|、\n                      (${B}˚${P}ˎ ${B}。${C}7\n                       |、~〵\n                       じしˍ,)⼃"
        "╱|、\n                      (${B}˚${P}ˎ ${B}。${C}7\n                       |、~〵\n                       じしˍ,)ノ"
    )
    for i in {1..6}; do
        clear
        frame_idx=$((i % 2))
        echo -e "${C}\n     ࿔‧ ֶָ֢˚˖𐦍˖˚ֶָ֢ ‧࿔       ${frames[frame_idx]}"
        sleep 0.4
    done
    echo -e "\n ${SYMBOL_CHAT} ${G}Goodbye! ${Y}(${C}-${R}.${C}-${Y})${C}Zzz・・・・ཐི|ཋྀ${N}\n"
    exit 0
}

# Function to run the selected exit animation
perform_exit() {
    echo -e "\n ${SYMBOL_ERR} ${R}Exiting Chat Tool...${N}\n"
    sleep 0.5
    if [ $RANDOM_EXIT_STYLE -eq 0 ]; then
        waving_exit
    else
        broken_exit
    fi
}

# --- 3. CHAT LOGIC FUNCTIONS ---

# Check for warnings specific to the current user
check_warnings() {
    local current_warnings
    # Fetch warnings, filter by username, and extract the warning message
    current_warnings=$(curl -s "$API_URL/warnings" | jq -r --arg user "$username" '.[] | select(.username == $user) | "⚠️ Warning: \(.warning)"' 2>/dev/null)
    
    if [ -n "$current_warnings" ]; then
        # Display warning prominently above the chat window
        echo -e "\n ${SYMBOL_WARN} ${R}SERVER ALERT FOR $username!${N}"
        echo -e " ${R}========================================${N}"
        echo -e " ${R}$current_warnings${N}"
        echo -e " ${R}========================================${N}\n"
    fi
}

# Check for ban status and exit if banned
check_ban_status() {
    local banned_message
    loading_animation
    
    # Fetch ban status, filter by username, and extract the ban message
    banned_message=$(curl -s "$API_URL/ban" | jq -r --arg user "$username" '.[] | select(.username == $user) | .bn_mesg' 2>/dev/null)
    
    if [ -n "$banned_message" ]; then
     clear
echo -e "\n     ${C}____    __    ____  _  _     _  _ "
echo -e "    ${C}(  _ \  /__\  (  _ \( )/ )___( \/ )"
echo -e "    ${Y} )(_) )/(__)\  )   / )  ((___))  ("
echo -e "   ${Y} (____/(__)(__)(_)\_)(_)\_)   (_/\_)\n"
        echo -e "         ${SYMBOL_ERR} ${R}YOU ARE BANNED, $username!${N}"
        echo -e "         ${R}Reason: $banned_message${N}"
        echo
        exit 0
    fi
}


# Main Chat Interface and Messaging Loop
display_messages() {
    check_ban_status # Check ban status before entering the loop
    
    while true; do
        clear
        loading_animation
        
        # --- Display Banner and Warnings ---
        
        # Date and Time Display
        local current_date=$(date +"${C}%Y-%b-%d${N}")
        local current_time=$(date +"${C}%I:%M %p${N}")
        echo -e "${lm}"
        echo -e " $current_date"
        echo -e "  ${C}┏┓┓┏┏┓┏┳┓"
        echo -e "  ${C}┃ ┣┫┣┫ ┃               ${SYMBOL_CHAT} ${G}t.me/Codex_369"
        echo -e "  ${C}┗┛┛┗┛┗ ┻"
        echo -e "  $current_time"
        echo -e "${lm}"

        check_warnings # Display dynamic warnings if present
        
        echo -e "\n ${C}╭${lm} ${C}MESSAGES ${C}${lm}╮"

        # --- Fetch and Display Messages (Robust JSON parsing) ---
        
        # Fetch, parse, and format messages
        local chat_log
        chat_log=$(curl -s "$API_URL/messages" | jq -r '.[] | "\(.username): \(.message)"' 2>/dev/null)
        
        if [ $? -eq 0 ] && [ -n "$chat_log" ]; then
            echo -e "${G}$chat_log${N}"
        else
            echo -e " ${SYMBOL_ERR} ${R}Could not load messages. API error or network issue.${N}"
        fi
        
        echo -e " ${C}╰${dm} ${C}ADS/INFO ${C}${dm}╯"
        
        # Fetch and display ads
        local ads_info
        ads_info=$(curl -s "$API_URL/ads" | jq -r '.[]' 2>/dev/null)
        if [ $? -eq 0 ] && [ -n "$ads_info" ]; then
            echo -e "${Y}$ads_info${N}\n"
        else
            echo -e " ${SYMBOL_INFO} ${C}No ads currently available.${N}\n"
        fi

        # --- User Input ---
        
        read -rp "${SYMBOL_ARROW} ${Y}Enter Message${N} | ${SYMBOL_USER}${username}${N} (Type ${R}q${N} to Exit) ──➤ " message
        
        if [[ "$message" == "q" ]]; then
            perform_exit
        elif [[ -z "$message" ]]; then
            # Ignore empty messages
            continue
        else
            # Send the message (Username padded with ' 〄 ' for style on server)
            curl -s -X POST -H "Content-Type: application/json" -d "{\"username\":\" 〄 $username\", \"message\":\"$message\"}" "$API_URL/send" &> /dev/null
            
            # Add a small delay for server processing and API refresh
            sleep 1.5
        fi
    done
}

# --- 4. USER REGISTRATION (Slightly improved validation) ---

# Function to handle username input and saving
save_username() {
    clear
    loading_animation
echo -e "\n        ${C}____    __    ____  _  _     _  _ "
echo -e "       ${C}(  _ \  /__\  (  _ \( )/ )___( \/ )"
echo -e "       ${Y} )(_) )/(__)\  )   / )  ((___))  ("
echo -e "      ${Y} (____/(__)(__)(_)\_)(_)\_)   (_/\_)\n\n"
    
    echo -e " ${SYMBOL_ARROW} ${C}Enter Your Anonymous ${G}Username${C}"
    echo
    
    local new_username
    while true; do
        read -rp "[+]──[Enter Your Username (3-12 chars)]────► " new_username
        
        if [[ -z "$new_username" ]]; then
            echo -e "${SYMBOL_ERR} ${R}Username cannot be empty!${N}"
        elif [[ ${#new_username} -lt 3 || ${#new_username} -gt 12 ]]; then
             echo -e "${SYMBOL_ERR} ${R}Username must be between 3 and 12 characters!${N}"
        elif ! [[ "$new_username" =~ ^[a-zA-Z0-9_-]+$ ]]; then
            echo -e "${SYMBOL_ERR} ${R}Only letters, numbers, hyphens, and underscores are allowed!${N}"
        else
            break
        fi
    done

    # Save the username
    mkdir -p "$USERNAME_DIR"
    echo "$new_username" > "$USERNAME_FILE"
    
    clear
    echo
    echo -e "		        ${G}Hey ${Y}$new_username"
    echo -e "${C}              (\_/)"
    echo -e "              (${Y}^ω^${C})     ${G}I'm Dx-Simu${C}"
    echo -e "             ⊂(___)づ  ⋅˚₊‧ ଳ ‧₊˚ ⋅"
    echo
    echo -e " ${SYMBOL_OK} ${C}Your account created ${G}Successfully!${C}"
    echo
    sleep 1
    echo -e " ${SYMBOL_INFO} ${C}Enjoy Our Chat Tool!${N}"
    echo
    read -rp "[+]──[Press ENTER to start chat]────► "
    
    # Set the global username variable
    username="$new_username"
    
    # Skip 'dx' help screen and go straight to chat loop
    display_messages
}

# --- 5. INITIAL EXECUTION FLOW ---

# 1. Install JQ if necessary (for reliable JSON parsing)
install_jq

# 2. Check and load/save username
if [ -f "$USERNAME_FILE" ]; then
    username=$(cat "$USERNAME_FILE")
    # 3. Check internet connection and start chat
    check_internet
    display_messages
else
    save_username
fi
