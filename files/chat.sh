#!/bin/bash
# Advanced Codex Chat Client - Enhanced by DX-SIMU

# --- Setup and Dependency Check ---
clear
# Check for essential tools: curl for API calls, jq for JSON parsing
for cmd in curl jq; do
    if ! command -v "$cmd" &> /dev/null; then
        echo " ${r}ERROR: ${y}$cmd${r} is not installed. Installing now...${n}"
        pkg install "$cmd" -y &> /dev/null
        if ! command -v "$cmd" &> /dev/null; then
            echo " ${E} ${r}FATAL: Failed to install $cmd. Cannot continue.${n}"
            exit 1
        fi
    fi
done
clear

# --- Color and Symbol Definitions ---
r='\033[1;91m' # Red
p='\033[1;95m' # Purple
y='\033[1;93m' # Yellow
g='\033[1;92m' # Green
n='\033[0m'    # No Color (Reset)
b='\033[1;94m' # Blue
c='\033[1;96m' # Cyan

# dx Symbol (Nerd Font dependent icons are recommended for full display)
E='\033[1;92m[\033[1;00m×\033[1;92m]\033[1;91m'
A='\033[1;92m[\033[1;00m+\033[1;92m]\033[1;92m'
C='\033[1;92m[\033[1;00m</>\033[1;92m]\033[92m'
lm='\033[1;96m▱▱▱▱▱▱\033[0m〄\033[1;96m▱▱▱▱▱▱\033[0m'
dm='\033[1;93m▱▱▱▱▱▱\033[0m〄\033[1;93m▱▱▱▱▱▱\033[0m'

# --- Global Configuration ---
URL="https://codex-chat-hew1.onrender.com"
USERNAME_DIR="$HOME/.DARK"
USERNAME_FILE="$USERNAME_DIR/usernames.txt"
random_number=$(( RANDOM % 2 )) # Used for random exit animation choice
local username # To be set after loading/saving

# --- Utility Functions ---

# Function for simple, fast loading animation
load() {
    clear
    echo -e " ${r}●${n}"
    sleep 0.1
    clear
    echo -e " ${r}●${y}●${n}"
    sleep 0.1
    clear
    echo -e " ${r}●${y}●${b}●${n}"
    sleep 0.1
    clear
}

# Function to safely retrieve and parse JSON data from the API
fetch_json_data() {
    local endpoint=$1
    local json

    # Use curl --fail and capture exit code
    json=$(curl -s --fail "$URL/$endpoint" 2>/dev/null)

    if [ $? -ne 0 ]; then
        echo -e " ${E} ${r}API Error: Failed to connect to $URL/$endpoint.${n}"
        return 1
    fi

    # Check if the response is valid JSON (using jq)
    if ! echo "$json" | jq . >/dev/null 2>&1; then
        echo -e " ${E} ${r}API Error: Received invalid JSON from $URL/$endpoint.${n}"
        return 1
    fi
    echo "$json"
}

# Advanced internet check with better display
inter() {
    clear
    echo
    echo -e "               ${g}╔═══════════════╗"
    echo -e "               ${g}║ ${n}</>  ${c}DARK-X${g}   ║"
    echo -e "               ${g}╚═══════════════╝"
    echo -e "  ${g}╔════════════════════════════════════════════╗"
    echo -e "  ${g}║  ${C} ${y}Checking Advanced Network Connectivity¡${g} ║"
    echo -e "  ${g}╚════════════════════════════════════════════╝${n}"
    while true; do
        # Check against a known reliable external site
        curl -s --head --fail https://google.com > /dev/null
        if [ "$?" != 0 ]; then
            echo -e "              ${g}╔══════════════════╗"
            echo -e "              ${g}║${C} ${r}No Internet ${g}║"
            echo -e "              ${g}╚══════════════════╝"
            sleep 2.5
        else
            break
        fi
    done
    clear
}

# Function to check and display user warnings
check_warnings() {
    local json
    json=$(fetch_json_data "warnings")

    if [ $? -ne 0 ]; then
        echo -e " ${E} ${r}Warning check failed (API error).${n}"
        return 1
    fi

    local warning
    # Format the warning with a Unicode emoji (Nerd Font compatible)
    warning=$(echo "$json" | jq -r --arg user "$username" '.[] | select(.username == $user) | "⚠️  WARNING: ${r}\(.username)${n} has been warned: ${y}\(.warning)${n}"' 2>/dev/null)

    if [ -n "$warning" ]; then
        echo -e "${lm}"
        echo -e " ${r}$warning${n}"
        echo -e "${dm}"
    fi
}

# Function to check for user ban before entering the chat loop
check_ban() {
    local json
    json=$(fetch_json_data "ban")

    if [ $? -ne 0 ]; then
        echo -e " ${E} ${r}Ban check failed (API error). Proceeding with caution.${n}"
        return 0
    fi

    local banned_msg
    # Filter the ban message for the current user
    banned_msg=$(echo "$json" | jq -r --arg user "$username" '.[] | select(.username == $user) | "🚨 ACCESS DENIED: \(.bn_mesg)"' 2>/dev/null)

    if [ -n "$banned_msg" ]; then
        load
        echo -e "     ${c}____    __    ____  _  _     _  _ "
        echo -e "    ${c}(  _ \  /__\  (  _ \( )/ )___( \/ )"
        echo -e "    ${y} )(_) )/(__)\  )   / )  ((___))  ("
        echo -e "   ${y} (____/(__)(__)(_)\_)(_)\_)   (_/\_)\n"
        echo -e "         ${r}${banned_msg}${n}"
        echo
        sleep 5
        exit 1
    fi
}

# Animated Exit Sequence 1: Heartbreak (broken)
broken() {
    local hearts=('˖<💌>' '𖥔˖<💘>.𖥔' '.𖥔 ˖<💘>.𖥔 ݁' '𖥔 ݁ ˖<💛>.𖥔 ݁' '.𖥔 ݁ ˖<💗>.𖥔 ݁ ˖' '₊ଳ ‧₊˚ ⋅.𖥔 ݁ ˖<💔>.𖥔 ݁ ˖⋅˚₊‧ ଳ₊')
    clear
    for heart in "${hearts[@]}"; do
        clear
        echo
        echo -e "${c}        _(\___/)"
        echo -e "      =( ´ ${g}•⁠${p}ω${g}• ⁠${c})=   ${heart}"
        echo -e "      // ͡     )︵)"
        echo -e "     (⁠人_____づ_づ"
        echo
        sleep 0.3
    done
    echo -e " ${C} ${g}Goodbye! ${y}(${c}-${r}.${c}-${y})${c}Zzz・・・・𑁍ࠬܓ"
    echo
    exit 0
}

# Animated Exit Sequence 2: Cat (goodbye)
goodbye() {
    local paws=('⼃' 'ノ')
    clear
    for i in {1..6}; do
        local paw_idx=$(( i % 2 ))
        clear
        echo
        echo -e "${c}     ࿔‧ ֶָ֢˚˖𐦍˖˚ֶָ֢ ‧࿔       ╱|、"
        echo -e "                      (${b}˚${p}ˎ ${b}。${c}7"
        echo -e "                       |、~〵"
        echo -e "                       じしˍ,)${paws[$paw_idx]}"
        echo
        sleep 0.3
    done
    echo -e " ${C} ${g}Goodbye! ${y}(${c}-${r}.${c}-${y})${c}Zzz・・・・ཐི|ཋྀ"
    echo
    exit 0
}

# Function to set up exit handler
exit_handler() {
    if [ $random_number -eq 0 ]; then
        goodbye
    else
        broken
    fi
}

# Set the trap to run the animated exit handler on script exit (including Ctrl+C/SIGINT)
trap exit_handler EXIT SIGINT

# Usage instructions before chat loop starts
dx() {
    clear
    echo
    echo -e " ${p}■ \e[4m${g}CHAT USAGE GUIDE\e[0m ${p}▪︎${n}"
    echo
    echo -e " ${y}Enter your message in the prompt below.${n}"
    echo
    echo -e " To exit the tool, type ${g}q ${y}and press Enter.${n}"
    echo -e "             q"
    echo
    echo -e " ${b}■ \e[4m${c}If you understand, click the Enter Button\e[0m ${b}▪︎${n}"
    read -p ""
}

# Main Chat Display Loop
display_messages() {
    # Check ban before starting the loop (trap will handle the exit)
    check_ban
    dx # Show usage instructions

    while true; do
        clear
        echo -e " ${r}●${y}●${b}●${n}"
        check_warnings

        # --- Header ---
        D=$(date +"${c}%Y-%b-%d${n}")
        T=$(date +"${c}%I:%M:%S %p${n}")
        echo -e "${lm}"
        echo -e " $D | $T ${A} ${g}SERVER: ${URL}"
        echo -e "  ${c}┏┓┓┏┏┓┏┳┓"
        echo -e "  ${c}┃ ┣┫┣┫ ┃               ${C} ${g}t.me/Pranabmallik"
        echo -e "  ${c}┗┛┛┗┛┗ ┻"
        echo -e "${lm}"
        echo -e " ${A} ${y}Recent Messages:${n}"
        echo -e "${dm}"

        # Fetch and display messages
        local msg_json
        msg_json=$(fetch_json_data "messages")

        if [ $? -ne 0 ]; then
            echo -e " ${E} ${r}Failed to load messages from the server.${n}"
        else
            # Advanced Formatting: Time, User, Message
            # Uses Unicode clock \u23F1
            echo "$msg_json" | jq -r '.[] | "\u23F1 ${c}\(.timestamp)${n} ${p}<${y}\(.username)${p}>: ${g}\(.message)${n}"'
        fi

        echo -e "${dm}"

        # Fetch and display ads
        local ads_json
        ads_json=$(fetch_json_data "ads")
        echo -e " ${A} ${c}Announcements/Ads:${n}"

        if [ $? -ne 0 ]; then
            echo -e " ${E} ${r}Failed to load ads.${n}"
        else
            # Formats ads with a blue diamond emoji \u274f
            echo "$ads_json" | jq -r '.[] | "  \u274f ${b}\(.)"'
        fi
        echo -e "${dm}"

        # --- Input Prompt ---
        read -p "${A}─[Send Message | ${y}${username}${n}]──➤ " message
        
        if [[ "$message" == "q" ]]; then
            echo -e "\n ${E} ${r}Exiting..Tool..!\n"
            exit 0 # Trigger the exit handler
        elif [[ -n "$message" ]]; then
            # Simple client-side timestamp added to the message payload
            local client_time=$(date "+%H:%M:%S")
            # POST message to the server, formatted with a gear \u269b
            curl -s -X POST -H "Content-Type: application/json" -d "{\"username\":\"\u269b ${username}\", \"message\":\"$message \u23F1 $client_time\"}" "$URL/send" &> /dev/null &
        fi
        
        # Add a short delay to prevent thrashing the server
        sleep 0.5
    done
}

# Function to manage username setup
save_username() {
    clear
    load
    echo -e "        ${c}____    __    ____  _  _     _  _ "
    echo -e "       ${c}(  _ \  /__\  (  _ \( )/ )___( \/ )"
    echo -e "       ${y} )(_) )/(__)\  )   / )  ((___))  ("
    echo -e "      ${y} (____/(__)(__)(_)\_)(_)\_)   (_/\_)\n\n"
    echo -e " ${A} ${c}Enter Your Anonymous ${g}Username${c}"
    echo
    
    local new_username
    read -p "[+]──[Enter Your Username]────► " new_username

    # Validate username
    if [[ -z "$new_username" ]]; then
        echo -e "${r}Username cannot be empty! Retrying.${n}"
        sleep 1
        save_username
        return
    fi

    # Set the global username variable
    username="$new_username"
    
    sleep 1
    clear
    echo
    echo -e "		        ${g}Hey ${y}$username"
    echo -e "${c}              (\_/)"
    echo -e "              (${y}^ω^${c})     ${g}I'm ＤＡＲＫ－ＰＲＩＮＣＥ  ايڪـͬــͤــᷜــͨــͣــͪـي${c}"
    echo -e "             ⊂(___)づ  ⋅˚₊‧ ଳ ‧₊˚ ⋅"
    echo
    echo -e " ${A} ${c}DARK Your Account Created ${g}Successfully¡${c}"
    
    # Save the username
    echo "$username" > "$USERNAME_FILE"
    echo
    sleep 1
    echo -e " ${A} ${c}Enjoy Our Chat Tool¡"
    echo
    read -p "[+]──[Enter to continue]────► "
}

# --- Main Execution ---

# 1. Ensure username directory exists
mkdir -p "$USERNAME_DIR"

# 2. Load or Save Username
if [ -f "$USERNAME_FILE" ]; then
    username=$(cat "$USERNAME_FILE")
    # Basic check to ensure it's not empty
    if [ -z "$username" ]; then
        save_username
    fi
else
    save_username
fi

# 3. Check internet connection
inter

# 4. Start displaying messages
display_messages
