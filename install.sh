#!/bin/bash

# Clear screen
clear

# ============================================
# COLOR DEFINITIONS
# ============================================
readonly RED='\033[1;91m'
readonly PURPLE='\033[1;95m'
readonly YELLOW='\033[1;93m'
readonly GREEN='\033[1;92m'
readonly RESET='\033[1;0m'
readonly BLUE='\033[1;94m'
readonly CYAN='\033[1;96m'
readonly LIME='\e[38;5;154m'
readonly NC='\e[0m'
readonly BLINK='\e[5m'

# ============================================
# SYMBOL DEFINITIONS
# ============================================
readonly X_SYMBOL='\033[1;92m[\033[1;00m⎯꯭̽𓆩\033[1;92m]\033[1;96m'
readonly D_SYMBOL='\033[1;92m[\033[1;00m〄\033[1;92m]\033[1;93m'
readonly E_SYMBOL='\033[1;92m[\033[1;00m×\033[1;92m]\033[1;91m'
readonly A_SYMBOL='\033[1;92m[\033[1;00m+\033[1;92m]\033[1;92m'
readonly C_SYMBOL='\033[1;92m[\033[1;00m</>\033[1;92m]\033[92m'
readonly LM_SYMBOL='\033[96m▱▱▱▱▱▱▱▱▱▱▱▱\033[0m〄\033[96m▱▱▱▱▱▱▱▱▱▱▱▱\033[1;00m'
readonly DM_SYMBOL='\033[93m▱▱▱▱▱▱▱▱▱▱▱▱\033[0m〄\033[93m▱▱▱▱▱▱▱▱▱▱▱▱\033[1;00m'

# ============================================
# ICON DEFINITIONS
# ============================================
readonly OS_ICON="\uf6a6"
readonly HOST_ICON="\uf6c3"
readonly KERNEL_ICON="\uf83c"
readonly UPTIME_ICON="\uf49b"
readonly PKGS_ICON="\uf8d6"
readonly SHELL_ICON="\ue7a2"
readonly TERMINAL_ICON="\uf489"
readonly CHIP_ICON="\uf2db"
readonly CPU_ICON="\ue266"
readonly HOME_ICON="\uf015"

# ============================================
# GLOBAL VARIABLES
# ============================================
readonly THRESHOLD=100
readonly CODEX_DIR="$HOME/.Codex-simu"
readonly TERMUX_DIR="$HOME/.termux"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly RANDOM_NUMBER=$(( RANDOM % 2 ))

# Device info
MODEL=$(getprop ro.product.model 2>/dev/null || echo "Unknown")
VENDOR=$(getprop ro.product.manufacturer 2>/dev/null || echo "Unknown")
DEVICE_NAME="${VENDOR} ${MODEL}"

# ============================================
# UTILITY FUNCTIONS
# ============================================

# Print with typewriter effect
type_effect() {
    local text="$1"
    local delay="${2:-0.05}"
    local term_width=$(tput cols)
    local text_length=${#text}
    local padding=$(( (term_width - text_length) / 2 ))
    
    printf "%${padding}s" ""
    
    for ((i=0; i<${#text}; i++)); do
        printf "${LIME}${BLINK}${text:$i:1}${NC}"
        
        # Random glitch effect
        if (( RANDOM % 3 == 0 )); then
            printf "${CYAN} ${NC}"
            sleep 0.05
            printf "\b"
        fi
        sleep "$delay"
    done
    echo
}

# Show spinner for long operations
show_spinner() {
    local pid=$!
    local delay=0.40
    local spinner=('█■■■■' '■█■■■' '■■█■■' '■■■█■' '■■■■█')
    
    while kill -0 $pid 2>/dev/null; do
        for i in "${spinner[@]}"; do
            tput civis
            echo -ne "\033[1;96m\r [+] Installing $1 please wait \e[33m[\033[1;92m$i\033[1;93m]\033[1;0m   "
            sleep $delay
            printf "\b\b\b\b\b\b\b\b"
        done
    done
    
    printf "   \b\b\b\b\b"
    tput cnorm
    printf "\e[1;93m [Done $1]\e[0m\n"
    echo
    sleep 1
}

# Check disk usage
check_disk_usage() {
    local threshold="${1:-$THRESHOLD}"
    local total_size used_size disk_usage
    
    if df -h "$HOME" &>/dev/null; then
        total_size=$(df -h "$HOME" | awk 'NR==2 {print $2}')
        used_size=$(df -h "$HOME" | awk 'NR==2 {print $3}')
        disk_usage=$(df "$HOME" | awk 'NR==2 {print $5}' | sed 's/%//g')
        
        if [ "$disk_usage" -ge "$threshold" ]; then
            echo -e "${GREEN}[${NC}\uf0a0${GREEN}] ${RED}WARN: ${YELLOW}Disk Full ${GREEN}${disk_usage}% ${CYAN}| ${CYAN}U${GREEN}${used_size} ${CYAN}of ${CYAN}T${GREEN}${total_size}"
        else
            echo -e "${YELLOW}Disk usage: ${GREEN}${disk_usage}% ${CYAN}| ${GREEN}${used_size}"
        fi
    else
        echo -e "${RED}Unable to check disk usage${RESET}"
    fi
}

# Check internet connection
check_internet() {
    if curl --silent --head --fail https://github.com > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Install required packages
install_packages() {
    echo -e "\n${CYAN}Updating package lists...${RESET}"
    apt update >/dev/null 2>&1 &
    show_spinner "apt update"
    
    echo -e "${CYAN}Upgrading packages...${RESET}"
    apt upgrade -y >/dev/null 2>&1 &
    show_spinner "apt upgrade"
    
    local packages=("git" "python" "ncurses-utils" "jq" "figlet" "termux-api" "lsd" "zsh" "ruby" "exa")
    
    for package in "${packages[@]}"; do
        if ! dpkg -l | grep -q "^ii  $package "; then
            echo -e "${CYAN}Installing $package...${RESET}"
            pkg install "$package" -y >/dev/null 2>&1 &
            show_spinner "$package"
        fi
    done
    
    # Install Python packages
    if ! pip show lolcat >/dev/null 2>&1; then
        echo -e "${CYAN}Installing lolcat...${RESET}"
        pip install lolcat >/dev/null 2>&1 &
        show_spinner "lolcat(pip)"
    fi
    
    # Install Ruby gem
    if ! gem list lolcat >/dev/null 2>&1; then
        echo -e "${CYAN}Installing advanced lolcat...${RESET}"
        echo "y" | gem install lolcat > /dev/null 2>&1 &
        show_spinner "lolcat「Advance」"
    fi
}

# Setup Termux configuration
setup_termux() {
    mkdir -p "$TERMUX_DIR"
    
    # Copy font if not exists
    if [ ! -f "$TERMUX_DIR/font.ttf" ]; then
        cp "$SCRIPT_DIR/files/font.ttf" "$TERMUX_DIR/"
    fi
    
    # Copy colors if not exists
    if [ ! -f "$TERMUX_DIR/colors.properties" ]; then
        cp "$SCRIPT_DIR/files/colors.properties" "$TERMUX_DIR/"
    fi
    
    # Copy figlet font
    mkdir -p "$PREFIX/share/figlet/"
    cp "$SCRIPT_DIR/files/ASCII-Shadow.flf" "$PREFIX/share/figlet/"
    
    # Install scripts
    if [ ! -f "/data/data/com.termux/files/usr/bin/chat" ]; then
        cp "$SCRIPT_DIR/files/chat.sh" "/data/data/com.termux/files/usr/bin/chat"
        chmod +x "/data/data/com.termux/files/usr/bin/chat"
    fi
    
    cp "$SCRIPT_DIR/files/remove" "/data/data/com.termux/files/usr/bin/"
    chmod +x "/data/data/com.termux/files/usr/bin/remove"
    
    termux-reload-settings
}

# Setup ZSH configuration
setup_zsh() {
    # Install oh-my-zsh if not exists
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo -e "${CYAN}Installing oh-my-zsh...${RESET}"
        git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh >/dev/null 2>&1 &
        show_spinner "oh-my-zsh"
    fi
    
    # Change shell to zsh
    if [ "$SHELL" != "/data/data/com.termux/files/usr/bin/zsh" ]; then
        echo -e "${CYAN}Changing shell to zsh...${RESET}"
        chsh -s zsh >/dev/null 2>&1 &
        show_spinner "zsh-shell"
    fi
    
    # Setup zshrc
    if [ ! -f "$HOME/.zshrc" ]; then
        echo -e "${CYAN}Setting up zshrc...${RESET}"
        rm -rf ~/.zshrc >/dev/null 2>&1
        cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc &
        show_spinner "zshrc"
    fi
    
    # Install zsh plugins
    if [ ! -d "$HOME/.oh-my-zsh/plugins/zsh-autosuggestions" ]; then
        echo -e "${CYAN}Installing zsh-autosuggestions...${RESET}"
        git clone https://github.com/zsh-users/zsh-autosuggestions \
            "$HOME/.oh-my-zsh/plugins/zsh-autosuggestions" >/dev/null 2>&1 &
        show_spinner "zsh-autosuggestions"
    fi
    
    if [ ! -d "$HOME/.oh-my-zsh/plugins/zsh-syntax-highlighting" ]; then
        echo -e "${CYAN}Installing zsh-syntax-highlighting...${RESET}"
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
            "$HOME/.oh-my-zsh/plugins/zsh-syntax-highlighting" >/dev/null 2>&1 &
        show_spinner "zsh-syntax"
    fi
}

# Create user banner
create_banner() {
    clear
    echo
    echo
    echo -e "${CYAN}              (\_/)"
    echo -e "              (${YELLOW}^_^${CYAN})     ${A_SYMBOL} ${GREEN}Hey dear${CYAN}"
    echo -e "             ⊂(___)づ  ⋅˚₊‧ ଳ ‧₊˚ ⋅"
    echo
    echo -e " ${A_SYMBOL} ${CYAN}Please Enter Your ${GREEN}Banner Name${CYAN}"
    echo
    
    # Validate name length (1-8 characters)
    local name=""
    while true; do
        read -p "[+]──[Enter Your Name]────► " name
        echo
        
        if [[ ${#name} -ge 1 && ${#name} -le 8 ]]; then
            break
        else
            echo -e " ${E_SYMBOL} ${RED}Name must be between ${GREEN}1 and 8${RED} characters. ${YELLOW}Please try again.${CYAN}"
            echo
        fi
    done
    
    # Create necessary directories
    mkdir -p "$TERMUX_DIR"
    mkdir -p "$HOME/.oh-my-zsh/themes"
    
    # Create configuration files
    echo "$name" > "$TERMUX_DIR/usernames.txt"
    echo "" > "$TERMUX_DIR/dx.txt"
    echo "" > "$TERMUX_DIR/ads.txt"
    
    # Process theme files
    if [ -f "$SCRIPT_DIR/files/.zshrc" ]; then
        sed "s/D1D4X/$name/g" "$SCRIPT_DIR/files/.zshrc" > "$HOME/.zshrc"
    fi
    
    if [ -f "$SCRIPT_DIR/files/.codex.zsh-theme" ]; then
        sed "s/D1D4X/$name/g" "$SCRIPT_DIR/files/.codex.zsh-theme" > \
            "$HOME/.oh-my-zsh/themes/codex.zsh-theme"
    fi
    
    clear
    echo
    echo
    echo -e "		        ${GREEN}Hey ${YELLOW}$name"
    echo -e "${CYAN}              (\_/)"
    echo -e "              (${YELLOW}^ω^${CYAN})     ${GREEN}I'm Dx-Simu${CYAN}"
    echo -e "             ⊂(___)づ  ⋅˚₊‧ ଳ ‧₊˚ ⋅"
    echo
    echo -e " ${A_SYMBOL} ${CYAN}Your Banner created ${GREEN}Successfully!${CYAN}"
    echo
    sleep 3
}

# Display main banner
display_banner() {
    clear
    echo
    echo
    echo -e "   ${YELLOW}░█████╗░░█████╗░██████╗░███████╗██╗░░██╗"
    echo -e "   ${YELLOW}██╔══██╗██╔══██╗██╔══██╗██╔════╝╚██╗██╔╝"
    echo -e "   ${YELLOW}██║░░╚═╝██║░░██║██║░░██║█████╗░░░╚███╔╝░"
    echo -e "   ${CYAN}██║░░██╗██║░░██║██║░░██║██╔══╝░░░██╔██╗░"
    echo -e "   ${CYAN}╚█████╔╝╚█████╔╝██████╔╝███████╗██╔╝╚██╗"
    echo -e "   ${CYAN}░╚════╝░░╚════╝░╚═════╝░╚══════╝╚═╝░░╚═╝${RESET}"
    echo -e "${YELLOW}               +-+-+-+-+-+-+-+-+"
    echo -e "${CYAN}               |D|S|-|C|O|D|E|X|"
    echo -e "${YELLOW}               +-+-+-+-+-+-+-+-+${RESET}"
    echo
    
    if [ $RANDOM_NUMBER -eq 0 ]; then
        echo -e "${BLUE}╭════════════════════════⊷"
        echo -e "${BLUE}┃ ${GREEN}[${NC}ム${GREEN}] ᴛɢ: ${YELLOW}t.me/Termuxcodex"
        echo -e "${BLUE}╰════════════════════════⊷"
    else
        echo -e "${BLUE}╭══════════════════════════⊷"
        echo -e "${BLUE}┃ ${GREEN}[${NC}ム${GREEN}] ᴛɢ: ${YELLOW}t.me/alphacodex369"
        echo -e "${BLUE}╰══════════════════════════⊷"
    fi
    
    echo
    echo -e "${BLUE}╭══ ${GREEN}〄 ${YELLOW}ᴄᴏᴅᴇx ${GREEN}〄"
    echo -e "${BLUE}┃❁ ${GREEN}ᴄʀᴇᴀᴛᴏʀ: ${YELLOW}ᴅx-ᴄᴏᴅᴇx"
    echo -e "${BLUE}┃❁ ${GREEN}ᴅᴇᴠɪᴄᴇ: ${YELLOW}${DEVICE_NAME}"
    echo -e "${BLUE}╰┈➤ ${GREEN}Hey ${YELLOW}Dear"
    echo
}

# Display menu banner
display_menu_banner() {
    display_banner
    echo -e "${CYAN}╭════════════════════════════════════════════════⊷"
    echo -e "${CYAN}┃ ${PURPLE}❏ ${GREEN}Choose what you want to use. then Click Enter${RESET}"
    echo -e "${CYAN}╰════════════════════════════════════════════════⊷"
}

# Show help message
show_help() {
    clear
    echo
    echo -e " ${PURPLE}■ \e[4m${GREEN}Use Button\e[4m ${PURPLE}▪︎${RESET}"
    echo
    echo -e " ${YELLOW}Use Termux Extra key Button${RESET}"
    echo
    echo -e " UP          ↑"
    echo -e " DOWN        ↓"
    echo
    echo -e " ${GREEN}Select option Click Enter button"
    echo
    echo -e " ${BLUE}■ \e[4m${CYAN}If you understand, click the Enter Button\e[4m ${BLUE}▪︎${RESET}"
    read -p ""
}

# Animated startup sequence
animated_start() {
    clear
    echo
    echo
    echo
    
    type_effect "[ CODEX STARTED]" 0.04
    sleep 0.2
    type_effect "「HELLO DEAR USER I•M DX-SIMU 」" 0.08
    sleep 0.5
    type_effect "【CODEX WILL PROTECT YOU】" 0.08
    sleep 0.7
    type_effect "<GOODBYE>" 0.08
    sleep 0.2
    type_effect "[ENJOY OUR CODEX]" 0.08
    sleep 0.5
    type_effect "!...............¡" 0.08
    echo
    sleep 2
    clear
}

# Exit handler
exit_script() {
    clear
    echo
    echo
    echo -e "${CYAN}              (\_/)"
    echo -e "              (${YELLOW}^_^${CYAN})     ${A_SYMBOL} ${GREEN}Hey dear${CYAN}"
    echo -e "             ⊂(___)づ  ⋅˚₊‧ ଳ ‧₊˚ ⋅"              
    echo -e "\n ${GREEN}[${RESET}${KERNEL_ICON}${GREEN}] ${CYAN}Exiting ${GREEN}Codex Banner \033[1;36m"
    echo
    cd "$HOME"
    rm -rf "$SCRIPT_DIR"
    exit 0
}

# Check internet with visual feedback
check_internet_with_feedback() {
    clear
    echo
    echo -e "               ${GREEN}╔═══════════════╗"
    echo -e "               ${GREEN}║ ${RESET}</>  ${CYAN}CODEX-X${GREEN}  ║"
    echo -e "               ${GREEN}╚═══════════════╝"
    echo -e "  ${GREEN}╔════════════════════════════════════════════╗"
    echo -e "  ${GREEN}║  ${C_SYMBOL} ${YELLOW}Checking Your Internet Connection!${GREEN}  ║"
    echo -e "  ${GREEN}╚════════════════════════════════════════════╝${RESET}"
    
    local attempts=0
    while [ $attempts -lt 3 ]; do
        if check_internet; then
            return 0
        fi
        
        echo -e "              ${GREEN}╔══════════════════╗"
        echo -e "              ${GREEN}║${C_SYMBOL} ${RED}No Internet ${GREEN}║"
        echo -e "              ${GREEN}╚══════════════════╝"
        sleep 2.5
        ((attempts++))
    done
    
    return 1
}

# Main setup function
main_setup() {
    # Check if running on Termux
    if [ ! -d "/data/data/com.termux/files/usr/" ]; then
        echo -e " ${E_SYMBOL} ${RED}Sorry, this operating system is not supported ${PURPLE}| ${GREEN}[${NC}${HOST_ICON}${GREEN}] ${SHELL}${RESET}"
        echo 
        echo -e " ${A_SYMBOL} ${GREEN} Wait for the next update using Linux...!${RESET}"
        echo
        sleep 3
        exit 1
    fi
    
    # Check internet
    if ! check_internet_with_feedback; then
        echo -e "${RED}No internet connection. Please check your connection and try again.${RESET}"
        exit 1
    fi
    
    display_banner
    echo -e " ${C_SYMBOL} ${YELLOW}Detected Termux on Android!${RESET}"
    echo -e " ${LM_SYMBOL}"
    echo -e " ${A_SYMBOL} ${GREEN}Updating Package..!${RESET}"
    echo -e " ${DM_SYMBOL}"
    echo -e " ${A_SYMBOL} ${GREEN}Wait a few minutes.${RESET}"
    echo -e " ${LM_SYMBOL}"
    
    # Install packages
    install_packages
    
    # Setup ZSH
    setup_zsh
    
    # Setup Termux
    setup_termux
    
    # Create banner
    create_banner
    
    # Final message
    clear
    display_banner
    echo -e " ${C_SYMBOL} ${CYAN}Type ${GREEN}exit ${CYAN}then ${GREEN}enter ${CYAN}Now Open Your Termux!! ${GREEN}[${NC}${HOME_ICON}${GREEN}]${RESET}"
    echo
    sleep 3
}

# Interactive menu
interactive_menu() {
    local options=("Free Usage" "Premium")
    local selected=0
    
    while true; do
        clear
        display_menu_banner
        echo
        echo -e " ${GREEN}■ \e[4m${PURPLE}Select An Option\e[0m ${GREEN}▪︎${RESET}"
        echo
        
        for i in "${!options[@]}"; do
            if [ $i -eq $selected ]; then
                echo -e " ${GREEN}〄> ${CYAN}${options[$i]} ${GREEN}<〄${RESET}"
            else
                echo -e "     ${options[$i]}"
            fi
        done
        
        # Read input
        read -rsn1 input
        
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
        elif [[ "$input" == "" ]]; then # Enter key
            case ${options[$selected]} in
                "Free Usage")
                    echo -e "\n ${GREEN}[${NC}${HOME_ICON}${GREEN}] ${CYAN}Continue Free..!${RESET}"
                    sleep 1
                    main_setup
                    exit 0
                    ;;
                "Premium")
                    echo -e "\n ${GREEN}[${NC}${HOST_ICON}${GREEN}] ${CYAN}Wait for opening Telegram..!${RESET}"
                    sleep 1
                    xdg-open "https://t.me/Codexownerbot" 2>/dev/null || \
                    echo -e "${YELLOW}Please visit: https://t.me/Codexownerbot${RESET}"
                    exit 0
                    ;;
            esac
        fi
    done
}

# ============================================
# MAIN EXECUTION
# ============================================

# Set trap for clean exit
trap exit_script SIGINT SIGTSTP

# Create Codex directory
mkdir -p "$CODEX_DIR"

# Start animated sequence
animated_start

# Show help
show_help

# Start interactive menu
interactive_menu
