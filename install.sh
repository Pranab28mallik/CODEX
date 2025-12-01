#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# Script: CODEX Advanced Termux Setup
# Author: DARK-PRINCE (Original Script)
# Modified: Gemini AI (For better structure, robustness, and UX)
# Purpose: Installs and configures Termux with ZSH, Oh My Zsh, plugins, 
#          custom colors, and a personalized banner.
# =========================================================================

# --- 1. CONFIGURATION AND STYLES ---

# Termux environment path check (important for Termux scripts)
PREFIX="/data/data/com.termux/files/usr"
HOME_DIR="$HOME"
TERMUX_DIR="$HOME_DIR/.termux"
CODEX_TEMP_DIR="$HOME_DIR/.Codex-simu"
TOOLS_DIR="$HOME_DIR/CODEX" # Directory where the initial files are expected

# Colors and Styling (Used standard ANSI for better compatibility)
R='\033[1;91m' # Red
P='\033[1;95m' # Purple
Y='\033[1;93m' # Yellow
G='\033[1;92m' # Green
N='\033[0m'    # Reset
B='\033[1;94m' # Blue
C='\033[1;96m' # Cyan

# Symbols for better UX
SYMBOL_OK="${G}[${N}✓${G}]${C}"
SYMBOL_WARN="${Y}[${N}!${Y}]${R}"
SYMBOL_ERR="${R}[${N}✗${R}]${R}"
SYMBOL_INFO="${B}[${N}i${B}]${C}"
SYMBOL_ARROW="${C}[${N}»${C}]${G}"
SYMBOL_LINE="${C}====================================================${N}"
SYMBOL_DIVIDER="${Y}----------------------------------------------------${N}"

# Device/System Info (Advanced checks)
MODEL_NAME=$(getprop ro.product.model 2>/dev/null || echo "Unknown Model")
VENDOR_NAME=$(getprop ro.product.manufacturer 2>/dev/null || echo "Unknown Vendor")
DEVICE_INFO="${VENDOR_NAME} ${MODEL_NAME}"
RANDOM_TG_CHOICE=$(( RANDOM % 2 )) # Random choice for Telegram link

# --- 2. CORE UTILITY FUNCTIONS ---

# Function to safely exit the script
exit_script() {
    clear
    echo -e "\n${SYMBOL_LINE}"
    echo -e "${C}              (\_/)"
    echo -e "              (${Y}^_^${C})     ${SYMBOL_OK} ${G}Hey dear${C}"
    echo -e "             ⊂(___)づ  ⋅˚₊‧ ଳ ‧₊˚ ⋅"              
    echo -e "${SYMBOL_LINE}"
    echo -e "\n ${SYMBOL_INFO} ${C}Exiting ${G}Codex Banner Setup...${N}"
    
    # Cleanup temporary files/directories
    rm -rf "$CODEX_TEMP_DIR" >/dev/null 2>&1
    rm -rf "$TOOLS_DIR" >/dev/null 2>&1
    
    echo -e "${SYMBOL_INFO} ${C}Cleanup complete. Goodbye!${N}\n"
    
    # Ensure Termux goes back to HOME, then exit
    cd "$HOME_DIR"
    exit 0
}

# Trap signals for graceful exit
trap exit_script SIGINT SIGTSTP

# Function to check and display disk usage (Refined)
check_disk_usage() {
    local threshold=${1:-75} # Lowered threshold for a more proactive warning
    local disk_usage
    local total_size
    local used_size

    # Use 'stat -f' for Termux-friendly filesystem stats
    disk_usage=$(df "$HOME_DIR" | awk 'NR==2 {print $5}' | sed 's/%//g')
    total_size=$(df -h "$HOME_DIR" | awk 'NR==2 {print $2}')
    used_size=$(df -h "$HOME_DIR" | awk 'NR==2 {print $3}')

    if [ -z "$disk_usage" ]; then
        echo -e "${SYMBOL_WARN} ${R}Disk Check Failed (df not found or output error).${N}"
        return 1
    fi
    
    if [ "$disk_usage" -ge "$threshold" ]; then
        echo -e "${SYMBOL_WARN} ${R}CRITICAL: Disk Usage High! ${Y}${disk_usage}% ${C}| Used: ${G}${used_size} ${C}of Total: ${G}${total_size}${N}"
    else
        echo -e "${SYMBOL_INFO} ${Y}Disk Usage: ${G}${disk_usage}% ${C}| Used: ${G}${used_size}${N}"
    fi
}

# Function for advanced type-effect animation (Original logic preserved)
type_effect_advanced() {
    local text="$1"
    local delay=${2:-0.04}
    local LIME='\e[38;5;154m'
    local CYAN='\e[36m'
    local BLINK='\e[5m'
    local NC='\e[0m'
    
    # Calculate padding for center alignment
    local term_width=$(tput cols 2>/dev/null || echo 80) # Default to 80 if tput fails
    local text_length=${#text}
    local padding=$(( (term_width - text_length) / 2 ))
    
    printf "%${padding}s" ""
    
    for ((i=0; i<${#text}; i++)); do
        printf "${LIME}${BLINK}${text:$i:1}${NC}"
        # Add random flicker for a hacker-like effect
        if (( RANDOM % 4 == 0 )); then
            printf "${CYAN} ${NC}"
            sleep 0.04
            printf "\b"
        fi
        sleep "$delay"
    done
    echo
}

# Function to show a clean help/instruction screen
show_help() {
    clear
    echo -e "\n${SYMBOL_LINE}"
    echo -e "${P}■ \e[4m${G}Termux Key Bindings / Instructions${N} ${P}▪︎${N}"
    echo -e "${SYMBOL_LINE}"
    echo -e " ${SYMBOL_ARROW} ${Y}UP Arrow${N}  : ${G}↑${N} (Menu Up)"
    echo -e " ${SYMBOL_ARROW} ${Y}DOWN Arrow${N}: ${G}↓${N} (Menu Down)"
    echo -e " ${SYMBOL_ARROW} ${Y}ENTER Key${N} : ${G}Select${N} the highlighted option"
    echo -e " ${SYMBOL_ARROW} ${Y}CTRL+C/Z${N}: ${R}Exit${N} the script gracefully (SIGINT/SIGTSTP)"
    echo -e "${SYMBOL_DIVIDER}"
    echo -e " ${B}■ \e[4m${C}Press ENTER to Continue with Setup${N} ${B}▪︎${N}"
    echo
    read -rp "" # Wait for user input
}

# --- 3. ANIMATION AND BANNERS ---

# Initial loading screen
start_animation() {
    clear
    echo
    echo
    echo
    type_effect_advanced "[ ＤＡＲＫ－ＰＲＩＮＣＥ  ايڪـͬــͤــᷜــͨــͣــͪـي ]" 0.03
    sleep 0.3
    type_effect_advanced "「HELLO DEAR OWNER ＤＡＲＫ－ＰＲＩＮＣＥ  ايڪـͬــͤــᷜــͨــͣــͪـي 」" 0.06
    sleep 0.5
    type_effect_advanced "【𝐏𝐑𝐈𝐍𝐂𝐄•°⚠︎︎ WILL PROTECT YOUR TERMINAL】" 0.06
    sleep 0.7
    type_effect_advanced "<INITIALIZING SYSTEM>" 0.08
    sleep 0.2
    type_effect_advanced "[ENJOY OUR 𝐏𝐑𝐈𝐍𝐂𝐄•°⚠︎︎ FEATURES]" 0.06
    sleep 0.5
    type_effect_advanced "!...............¡" 0.08
    echo
    sleep 1.5
    clear 
    mkdir -p "$CODEX_TEMP_DIR" # Create temp directory early
}

# Main Setup Banner (Improved Aesthetics)
main_banner() {
    clear
    echo
    echo -e "   ${Y}░█████╗░░█████╗░██████╗░███████╗██╗░░██╗"
    echo -e "   ${Y}██╔══██╗██╔══██╗██╔══██╗██╔════╝╚██╗██╔╝"
    echo -e "   ${Y}██║░░╚═╝██║░░██║██║░░██║█████╗░░░╚███╔╝░"
    echo -e "   ${C}██║░░██╗██║░░██║██║░░██║██╔══╝░░░██╔██╗░"
    echo -e "   ${C}╚█████╔╝╚█████╔╝██████╔╝███████╗██╔╝╚██╗"
    echo -e "   ${C}░╚════╝░░╚════╝░╚═════╝░╚══════╝╚═╝░░╚═╝${N}"
    echo -e "${Y}               +-+-+-+-+-+-+-+-+"
    echo -e "${C}               ＤＡＲＫ－ＰＲＩＮＣＥ  ايڪـͬــͤــᷜــͨــͣــͪـي"
    echo -e "${Y}               +-+-+-+-+-+-+-+-+${N}"
    echo
    
    # Dynamic Telegram Link
    if [ $RANDOM_TG_CHOICE -eq 0 ]; then
        echo -e "${B}╭════════════════════════⊷"
        echo -e "${B}┃ ${G} ${SYMBOL_INFO} TG: ${Y}t.me/Termuxcodex"
        echo -e "${B}╰════════════════════════⊷"
    else
        echo -e "${B}╭══════════════════════════⊷"
        echo -e "${B}┃ ${G} ${SYMBOL_INFO} TG: ${Y}t.me/alphacodex369"
        echo -e "${B}╰══════════════════════════⊷"
    fi
    
    echo
    echo -e "${B}╭══ ${G}〄 ${Y}𝐏𝐑𝐈𝐍𝐂𝐄•°⚠︎︎ ${G}〄"
    echo -e "${B}┃❁ ${G}ᴄʀᴇᴀᴛᴏʀ: ${Y}ＤＡＲＫ－ＰＲＩＮＣＥ  ايڪـͬــͤــᷜــͨــͣــͪـي"
    echo -e "${B}┃❁ ${G}ᴅᴇᴠɪᴄᴇ: ${Y}${DEVICE_INFO}"
    echo -e "${B}╰┈➤ ${G}Status: ${C}$(check_disk_usage)${N}"
    echo
}

# --- 4. INSTALLATION AND SETUP FUNCTIONS ---

# Function for package installation with a modern spinner
install_spinner() {
    local package_name=$1
    local install_cmd=$2
    local delay=0.1
    local spinner=('◒' '◐' '◓' '◑')
    local pid
    
    # Check if package is already installed (dpkg-l for pkg/apt)
    if dpkg -l | grep -q "^ii  $package_name " && [[ "$package_name" != "lolcat(pip)" && "$package_name" != "lolcat(gem)" ]]; then
        echo -e "${SYMBOL_OK} ${Y}$package_name${C} already installed. Skipping.${N}"
        return 0
    fi

    # Run installation command in background
    (eval "$install_cmd") >/dev/null 2>&1 &
    pid=$!

    # Spinner logic
    while kill -0 $pid 2>/dev/null; do
        for i in "${spinner[@]}"; do
            tput civis # Hide cursor
            echo -ne "\r ${SYMBOL_ARROW} Installing ${Y}$package_name${C}... ${G}[${i}]${N}   "
            sleep $delay
        done
    done
    tput cnorm # Show cursor
    
    wait $pid
    if [ $? -eq 0 ]; then
        echo -e "\r ${SYMBOL_OK} ${Y}$package_name${C} installed successfully.${N}        "
    else
        echo -e "\r ${SYMBOL_ERR} ${R}Failed to install ${Y}$package_name${R}. Check internet/repository.${N} "
    fi
}

# Core dependency installation and check
install_dependencies() {
    main_banner
    echo -e " ${SYMBOL_LINE}"
    echo -e " ${SYMBOL_INFO} ${G}Performing initial checks and updates...${N}"
    echo -e " ${SYMBOL_LINE}"
    
    # Initial Update/Upgrade (in background for faster spinner start)
    (apt update -y && apt upgrade -y) >/dev/null 2>&1 &
    install_spinner "System Update" "wait" # Dummy command to keep spinner running during update
    
    # Array of packages and their install commands
    declare -A packages=(
        ["curl"]="pkg install curl -y"
        ["ncurses-utils"]="pkg install ncurses-utils -y"
        ["git"]="pkg install git -y"
        ["python"]="pkg install python -y"
        ["jq"]="pkg install jq -y"
        ["figlet"]="pkg install figlet -y"
        ["termux-api"]="pkg install termux-api -y"
        ["lsd"]="pkg install lsd -y"
        ["zsh"]="pkg install zsh -y"
        ["ruby"]="pkg install ruby -y"
        ["exa"]="pkg install exa -y"
        ["lolcat(pip)"]="pip install lolcat"
        ["lolcat(gem)"]="gem install lolcat"
    )

    for package in "${!packages[@]}"; do
        install_spinner "$package" "${packages[$package]}"
    done

    echo -e "\n ${SYMBOL_LINE}"
    echo -e " ${SYMBOL_OK} ${G}All dependencies checked/installed.${N}"
    echo -e " ${SYMBOL_LINE}\n"
}

# ZSH and Oh-My-ZSH Setup
setup_zsh_ohmyzsh() {
    main_banner
    echo -e " ${SYMBOL_LINE}"
    echo -e " ${SYMBOL_INFO} ${G}Setting up ZSH and Oh My Zsh environment...${N}"
    echo -e " ${SYMBOL_LINE}"

    # Oh My Zsh Clone
    if [ ! -d "$HOME_DIR/.oh-my-zsh" ]; then
        install_spinner "Oh-My-Zsh" "git clone https://github.com/ohmyzsh/ohmyzsh.git $HOME_DIR/.oh-my-zsh"
    else
        echo -e "${SYMBOL_OK} ${Y}Oh-My-Zsh${C} directory found. Skipping clone.${N}"
    fi

    # Plugins Clone
    local plugins_dir="$HOME_DIR/.oh-my-zsh/plugins"
    if [ ! -d "$plugins_dir/zsh-autosuggestions" ]; then
        install_spinner "zsh-autosuggestions" "git clone https://github.com/zsh-users/zsh-autosuggestions $plugins_dir/zsh-autosuggestions"
    else
        echo -e "${SYMBOL_OK} ${Y}zsh-autosuggestions${C} plugin found. Skipping clone.${N}"
    fi

    if [ ! -d "$plugins_dir/zsh-syntax-highlighting" ]; then
        install_spinner "zsh-syntax-highlighting" "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $plugins_dir/zsh-syntax-highlighting"
    else
        echo -e "${SYMBOL_OK} ${Y}zsh-syntax-highlighting${C} plugin found. Skipping clone.${N}"
    fi

    # ZSH Shell Change
    if [ "$SHELL" != "$PREFIX/bin/zsh" ]; then
        install_spinner "ZSH Shell Change" "chsh -s $PREFIX/bin/zsh"
    else
        echo -e "${SYMBOL_OK} ${Y}ZSH${C} is already the default shell.${N}"
    fi
    
    # ZSHRC Creation
    if [ ! -f "$HOME_DIR/.zshrc" ]; then
        # Use template if .zshrc doesn't exist (temporary for the next step)
        install_spinner "zshrc file creation" "cp $HOME_DIR/.oh-my-zsh/templates/zshrc.zsh-template $HOME_DIR/.zshrc"
    else
        echo -e "${SYMBOL_OK} ${Y}.zshrc${C} found. Will be customized next.${N}"
    fi
    
    # Cleanup MOTD
    if [ -f "$PREFIX/etc/motd" ]; then
        echo -e "${SYMBOL_INFO} ${C}Cleaning up default MOTD.${N}"
        rm -f "$PREFIX/etc/motd" >/dev/null 2>&1
    fi
    
    echo -e "\n ${SYMBOL_LINE}"
    echo -e " ${SYMBOL_OK} ${G}ZSH setup complete.${N}"
    echo -e " ${SYMBOL_LINE}\n"
}

# Final Termux Configuration and Customization (Colors, Fonts, Banner)
setup_termux_customization() {
    main_banner
    echo -e " ${SYMBOL_LINE}"
    echo -e " ${SYMBOL_INFO} ${G}Applying Codex theme and customizations...${N}"
    echo -e " ${SYMBOL_LINE}"
    
    # Check if tools directory exists
    if [ ! -d "$TOOLS_DIR" ]; then
        echo -e "\n ${SYMBOL_ERR} ${R}Fatal Error: Required files directory (${TOOLS_DIR}) not found.${N}"
        echo -e " ${R}Please ensure the initial 'CODEX' folder is present and run again.${N}"
        exit 1
    fi

    mkdir -p "$TERMUX_DIR"

    # Font and Colors Setup
    install_spinner "Font and Colors" "cp $TOOLS_DIR/files/font.ttf $TERMUX_DIR/font.ttf && cp $TOOLS_DIR/files/colors.properties $TERMUX_DIR/colors.properties"

    # Figlet Font Setup
    install_spinner "Figlet Font (ASCII-Shadow)" "cp $TOOLS_DIR/files/ASCII-Shadow.flf $PREFIX/share/figlet/"

    # Utility Commands Setup
    install_spinner "Utility: remove" "mv $TOOLS_DIR/files/remove $PREFIX/bin/ && chmod +x $PREFIX/bin/remove"
    install_spinner "Utility: chat" "mv $TOOLS_DIR/files/chat.sh $PREFIX/bin/chat && chmod +x $PREFIX/bin/chat"

    # Codex internal files setup
    install_spinner "Codex Report File" "mv $TOOLS_DIR/files/report $CODEX_TEMP_DIR/report"
    install_spinner "Codex Theme Move" "mv $TOOLS_DIR/files/.codex.zsh-theme $HOME_DIR/.oh-my-zsh/themes/"
    
    # Reload settings
    echo -e "${SYMBOL_INFO} ${C}Reloading Termux settings... (Requires Termux-API)${N}"
    termux-reload-settings 2>/dev/null || echo -e "${SYMBOL_WARN} ${Y}Could not reload settings. Restart Termux manually.${N}"
    
    echo -e "\n ${SYMBOL_LINE}"
    echo -e " ${SYMBOL_OK} ${G}Customization files deployed.${N}"
    echo -e " ${SYMBOL_LINE}\n"
}

# Personalized Banner Name Setup
set_personalized_banner() {
    clear
    echo
    echo
    echo -e ""
    echo -e "${C}              (\_/)"
    echo -e "              (${Y}^_^${C})     ${SYMBOL_OK} ${G}Hey dear${C}"
    echo -e "             ⊂(___)づ  ⋅˚₊‧ ଳ ‧₊˚ ⋅"
    echo
    echo -e " ${SYMBOL_ARROW} ${C}Please Enter Your ${G}Banner Name${C}"
    echo

    local name
    local temp_zshrc="$HOME_DIR/temp_zshrc_$$" # Unique temp file name
    
    # Loop to prompt until valid name (1-8 characters)
    while true; do
        read -rp "[+]──[Enter Your Name (1-8 chars)]────► " name
        echo

        # Input validation
        if [[ ${#name} -ge 1 && ${#name} -le 8 && "$name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
            break  # Valid, proceed
        else
            echo -e " ${SYMBOL_ERR} ${R}Name must be ${G}1-8 characters${R} (A-Z, 0-9, _, - only). ${Y}Please try again.${N}"
            echo
        fi
    done

    echo -e "\n ${SYMBOL_INFO} ${C}Applying customization to ZSH configuration...${N}"

    # 1. Custom ZSHRC: Replace the placeholder 'PRINCE' with user's name
    if ! sed "s/PRINCE/$name/g" "$TOOLS_DIR/files/.zshrc" > "$temp_zshrc"; then
         echo -e " ${SYMBOL_ERR} ${R}ZSHRC processing failed! Aborting.${N}"
         rm -f "$temp_zshrc"
         exit 1
    fi
    mv "$temp_zshrc" "$HOME_DIR/.zshrc"
    
    # 2. Custom ZSH Theme: Replace placeholder in the theme file
    sed -i "s/PRINCE/$name/g" "$HOME_DIR/.oh-my-zsh/themes/codex.zsh-theme"
    
    # 3. Store the name for future use
    echo "$name" > "$TERMUX_DIR/usernames.txt" 
    echo "" > "$TERMUX_DIR/dx.txt" # version file (assuming this is intentional)
	echo "" > "$TERMUX_DIR/ads.txt" # ads file (assuming this is intentional)


    # Final success message
    clear
    echo
    echo
    echo -e "		        ${G}Hey ${Y}$name"
    echo -e "${C}              (\_/)"
    echo -e "              (${Y}^ω^${C})     ${G}I'm Dx-Simu${C}"
    echo -e "             ⊂(___)づ  ⋅˚₊‧ ଳ ‧₊˚ ⋅"
    echo
    echo -e " ${SYMBOL_OK} ${C}Your Banner and Setup created ${G}Successfully!${C}"
    echo -e " ${SYMBOL_ARROW} ${G}Configuration complete.${C} Starting new ZSH session.${N}"
    sleep 3
}

# --- 5. INTERNET AND ENVIRONMENT CHECK ---

# Robust Internet Check
dxnetcheck() {
    clear
    main_banner
    echo -e "  ${G}╔════════════════════════════════════════════╗"
    echo -e "  ${G}║  ${SYMBOL_INFO} ${Y}Checking Your Internet Connection...${G} ║"
    echo -e "  ${G}╚════════════════════════════════════════════╝${N}"
    
    # Ensure curl is available for checking
    if ! command -v curl &>/dev/null; then
        echo -e " ${SYMBOL_WARN} ${Y}Curl not found. Attempting to install for network check.${N}"
        pkg install curl -y >/dev/null 2>&1
        if [ $? -ne 0 ]; then
             echo -e " ${SYMBOL_ERR} ${R}Cannot install Curl. Network check aborted.${N}"
             # Proceed anyway, but warn
        fi
    fi

    # Loop until network is available (or ctrl+c)
    while true; do
        if curl --silent --head --fail https://github.com > /dev/null; then
            echo -e " ${SYMBOL_OK} ${G}Internet connection is UP.${N}"
            sleep 1
            break
        else
            echo -e "              ${G}╔══════════════════╗"
            echo -e "              ${G}║${SYMBOL_ERR} ${R}No Internet ${G}║"
            echo -e "              ${G}╚══════════════════╝"
            echo -e " ${SYMBOL_INFO} ${C}Please connect to the internet to proceed.${N}"
            sleep 3
        fi
    done
    clear
}

# Core Setup Logic
core_setup_logic() {
    # 1. Environment Check
    if [ ! -d "/data/data/com.termux/files/usr/" ]; then
        clear
        echo -e "\n ${SYMBOL_ERR} ${R}Sorry, this operating system is not supported.${N}"
        echo -e " ${SYMBOL_INFO} ${C}This script is designed for Termux on Android only.${N}"
        echo -e " ${SYMBOL_INFO} ${G}Wait for the next update using Linux...!${N}"
        sleep 4
        exit 1
    fi
    
    # 2. Check for required initial files
    if [ ! -d "$TOOLS_DIR" ]; then
        clear
        main_banner
        echo -e "\n ${SYMBOL_ERR} ${R}Tools Directory (${TOOLS_DIR}) Not Found.${N}"
        echo -e " ${SYMBOL_INFO} ${C}Please ensure the setup is run from the correct initial path.${N}"
        sleep 4
        exit 1
    fi

    # 3. Network Check
    dxnetcheck
    
    # 4. Installation Steps
    install_dependencies
    setup_zsh_ohmyzsh
    setup_termux_customization
    set_personalized_banner

    # 5. Final Exit
    clear
    main_banner
    echo -e " ${SYMBOL_OK} ${G}SETUP COMPLETE!${N}"
    echo -e " ${SYMBOL_ARROW} ${C}Type ${G}exit${C} (or restart Termux) to launch your new environment.${N}"
    echo -e " ${SYMBOL_INFO} ${C}Cleaning up initial setup folder...${N}"
    
    # Final cleanup
    rm -rf "$TOOLS_DIR" >/dev/null 2>&1
    
    sleep 4
    exit 0 # Exit successfully after cleanup
}

# --- 6. USER INTERFACE (MENU) ---

# Menu options for the user
declare -a options=("Free Usage (Install and Setup)" "Premium (Contact Creator)")
selected=0

# Function to display the main choice menu
display_main_menu() {
    clear
    main_banner
    echo -e "${C}╭════════════════════════════════════════════════⊷"
    echo -e "${C}┃ ${P}❏ ${G}Choose your option, then click Enter.${N}"
    echo -e "${C}╰════════════════════════════════════════════════⊷"
    echo
    
    # Display options
    for i in "${!options[@]}"; do
        if [ $i -eq $selected ]; then
            echo -e " ${G}〄> ${C}${options[$i]} ${G}<〄${N}"
        else
            echo -e "     ${options[$i]}"
        fi
    done
    echo
}

# Main menu loop to handle user interaction
main_menu_loop() {
    while true; do
        display_main_menu
        read -rsn1 input # Read single, silent character
        
        # Check for escape sequences (arrow keys)
        if [[ "$input" == $'\e' ]]; then
            read -rsn2 -t 0.1 input
            case "$input" in
                '[A') # Up arrow
                    ((selected--))
                    if [ $selected -lt 0 ]; then
                        selected=$((${#options[@]} - 1))
                    fi
                    ;;
                '[B') # Down arrow
                    ((selected++))
                    if [ $selected -ge ${#options[@]} ]; then
                        selected=0
                    fi
                    ;;
            esac
        
        # Check for Enter key
        elif [[ "$input" == "" ]]; then 
            case ${options[$selected]} in
                "Free Usage (Install and Setup)")
                    echo -e "\n ${SYMB
