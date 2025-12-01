#!/bin/bash
# Advanced CODEX Banner and Setup Script
# Developed by Dx-Simu (Enhanced Version)
set -e # Exit immediately if a command exits with a non-zero status.

# --- 1. DX Color & Symbol Definitions ---
r='\033[1;91m' # Red
p='\033[1;95m' # Purple
y='\033[1;93m' # Yellow
g='\033[1;92m' # Green
n='\033[0m'    # No Color (Reset)
b='\033[1;94m' # Blue
c='\033[1;96m' # Cyan

# dx Symbol (Enhanced readability)
X='\033[1;92m[\033[1;00m—꯭̽𓆩\033[1;92m]\033[1;96m'
D='\033[1;92m[\033[1;00m〄\033[1;92m]\033[1;93m'
E='\033[1;92m[\033[1;00m×\033[1;92m]\033[1;91m'
A='\033[1;92m[\033[1;00m+\033[1;92m]\033[1;92m'
C='\033[1;92m[\033[1;00m</>\033[1;92m]\033[92m'
lm='\033[96m▱▱▱▱▱▱▱▱▱▱▱▱\033[0m〄\033[96m▱▱▱▱▱▱▱▱▱▱▱▱\033[0m'
dm='\033[93m▱▱▱▱▱▱▱▱▱▱▱▱\033[0m〄\033[93m▱▱▱▱▱▱▱▱▱▱▱▱\033[0m'

# dx icon (Unicode Font needed for best display)
OS="\uf6a6"
HOST="\uf6c3"
KER="\uf83c"
UPT="\uf49b"
PKGS="\uf8d6"
SH="\ue7a2"
TERMINAL="\uf489"
CHIP="\uf2db"
CPUI="\ue266"
HOMES="\uf015"
BAT="\uf242" # Battery icon
NET="\uf6ff" # Network icon

# System Variables
MODEL=$(getprop ro.product.model)
VENDOR=$(getprop ro.product.manufacturer)
devicename="${VENDOR} ${MODEL}"
THRESHOLD=90 # Lowered threshold slightly to warn earlier
random_number=$(( RANDOM % 2 ))

# --- 2. Utility Functions ---

exit_script() {
    clear
    echo
    echo
    echo -e "${c}              (\_/)"
    echo -e "              (${y}^_^${c})     ${A} ${g}Goodbye, dear.${c}"
    echo -e "             ⊂(___)づ  ⋅˚₊‧ ଳ ‧₊˚ ⋅"
    echo
    echo -e " ${g}[${n}${KER}${g}] ${c}Exiting ${g}Codex Banner Setup \033[1;36m"
    echo -e " ${g}[${n}${HOMES}${g}] ${c}Type ${g}zsh ${c}or reopen Termux to load new banner!"
    echo
    cd "$HOME"
    rm -rf "$HOME/CODEX" 2>/dev/null
    exit 0
}

trap exit_script SIGINT SIGTSTP

# Checks disk usage and reports warning if above threshold
check_disk_usage() {
    local threshold=${1:-$THRESHOLD}
    local total_size used_size disk_usage

    # Try to use busybox df first, if available and faster
    if command -v df >/dev/null 2>&1; then
        # df -h output example: /dev/root 10G 5.0G 5.0G 50% /
        # We need the 5th column (usage %) and the 2nd/3rd (Total/Used)
        read -r _ total_size used_size _ disk_usage _ <<< "$(df -h "$HOME" | awk 'NR==2 {print $2, $3, $5}')"
        disk_usage=$(echo "$disk_usage" | sed 's/%//g')
    else
        echo -e "${E} ${r}Error: 'df' command not found."
        return 1
    fi

    # Check if the disk usage exceeds the threshold
    if [ -n "$disk_usage" ] && [ "$disk_usage" -ge "$threshold" ]; then
        echo -e "${g}[${n}\uf0a0${g}] ${r}WARN: ${y}Disk Full ${g}${disk_usage}% ${c}| ${c}U:${g}${used_size} ${c}of ${c}T:${g}${total_size}"
    else
        echo -e "${y}Disk usage: ${g}${disk_usage}% ${c}| ${g}${used_size}"
    fi
}

# Advanced dynamic system info gathering (requires termux-api and curl)
get_dynamic_info() {
    # 1. Battery Status
    local battery_info=""
    if command -v termux-battery-status &>/dev/null; then
        local status=$(termux-battery-status | jq -r '.status')
        local level=$(termux-battery-status | jq -r '.percentage')
        local current_temp=$(termux-battery-status | jq -r '.temperature') # in Celsius
        local temp_f=$(echo "scale=1; $current_temp * 9 / 5 + 32" | bc)
        battery_info="${level}% (${status}) | ${current_temp}°C / ${temp_f}°F"
    else
        battery_info="N/A (Install termux-api)"
    fi

    # 2. Public IP Address
    local public_ip=""
    if command -v curl &>/dev/null; then
        # Use a fast, reliable service, with a timeout
        public_ip=$(curl -s --connect-timeout 2 "ifconfig.me/ip" | tr -d '\n')
        if [ -z "$public_ip" ]; then
             public_ip="Failed to fetch"
        fi
    else
        public_ip="N/A (Install curl)"
    fi

    # 3. Uptime
    local uptime_str=""
    if command -v uptime &>/dev/null; then
        uptime_str=$(uptime -p 2>/dev/null) # Get human-readable format
        if [ -z "$uptime_str" ]; then
            uptime_str=$(cat /proc/uptime | awk '{printf "%d hours, %d minutes\n", $1/3600, ($1%3600)/60}')
        fi
    else
        uptime_str="N/A"
    fi

    echo -e "${g}[${n}${BAT}${g}] ${c}Battery: ${y}${battery_info}"
    echo -e "${g}[${n}${NET}${g}] ${c}Public IP: ${y}${public_ip}"
    echo -e "${g}[${n}${UPT}${g}] ${c}Uptime: ${y}${uptime_str}"
}

# Screen Print effect
sp() {
    IFS=''
    sentence=$1
    second=${2:-0.05}
    for (( i=0; i<${#sentence}; i++ )); do
        char=${sentence:$i:1}
        echo -n "$char"
        sleep $second
    done
    echo
}

# Typewriter effect for initial start (Simplified)
type_effect() {
    local text="$1"
    local delay=$2
    local term_width=$(tput cols 2>/dev/null || echo 80)
    local text_length=${#text}
    local padding=$(( (term_width - text_length) / 2 ))
    printf "%${padding}s" ""
    for ((i=0; i<${#text}; i++)); do
        printf "${c}${text:$i:1}${n}"
        sleep "$delay"
    done
    echo
}

start() {
    clear
    LIME='\e[38;5;154m'
    CYAN='\e[36m'
    NC='\e[0m'
    
    echo
    echo
    echo
    type_effect "[ CODEX SYSTEM INITIALIZING ]" 0.04
    sleep 0.2
    type_effect "「HELLO DEAR USER I'M DX-SIMU A.I.」" 0.08
    sleep 0.5
    type_effect "【LOADING ADVANCED MODULES...】" 0.08
    sleep 0.7
    type_effect "<SYSTEM CHECK COMPLETE>" 0.08
    sleep 0.2
    type_effect "[ENJOY THE ADVANCED CODEX TERMINAL]" 0.08
    sleep 0.5
    type_effect "!...............¡" 0.08
    echo
    sleep 2
    clear
}

# --- 3. Setup & Installation Functions ---

# Basic tool check (moved outside spin for earlier checks)
tr() {
    # Check if essential tools are installed, install if not
    for cmd in curl ncurses-utils bc jq; do
        if ! command -v "$cmd" &>/dev/null; then
            echo -e " ${A} ${g}Installing essential tool: ${y}$cmd${n}"
            pkg install "$cmd" -y >/dev/null 2>&1 || { echo -e " ${E} ${r}Failed to install $cmd"; exit 1; }
        fi
    done
}

help() {
    clear
    echo
    echo -e " ${p}■ \e[4m${g}Use Termux Key Buttons\e[0m ${p}▪︎${n}"
    echo
    echo -e " ${y}Termux Extra Key Buttons${n}"
    echo
    echo -e " UP          ${g}↑${n} (Move Selection Up)"
    echo -e " DOWN        ${g}↓${n} (Move Selection Down)"
    echo
    echo -e " ${g}Select option: Click ${y}ENTER ${g}button"
    echo
    echo -e " ${b}■ \e[4m${c}If you understand, click the Enter Button\e[0m ${b}▪︎${n}"
    read -p ""
}

# Advanced Spinner function for installation
spin() {
    echo
    local delay=0.1
    local spinner=('◒' '◓' '◑' '◔')

    show_spinner() {
        local pid=$!
        local pkg_name=$1
        echo -ne "\033[1;96m [+] Installing $pkg_name please wait \e[33m[\033[1;92m"
        while ps -p $pid > /dev/null; do
            for i in "${spinner[@]}"; do
                tput civis # Hide cursor
                echo -ne "$i\033[1;93m]\033[0m   "
                sleep $delay
                printf "\b\b\b\b"
            done
        done
        tput cnorm # Show cursor
        printf "   \b\b\b\b\b"
        printf "\e[1;93m [Done $pkg_name]\e[0m\n"
        sleep 0.5
    }

    echo -e " ${A} ${g}Updating package repositories...${n}"
    apt update -y >/dev/null 2>&1
    apt upgrade -y >/dev/null 2>&1
    
    # Core packages
    packages=("git" "python" "ncurses-utils" "jq" "figlet" "termux-api" "lsd" "zsh" "ruby" "exa" "neofetch" "htop" "openssh")

    for package in "${packages[@]}"; do
        if ! dpkg -l | grep -q "^ii\s*$package\s"; then
            pkg install "$package" -y >/dev/null 2>&1 &
            show_spinner "$package"
        fi
    done

    # Python lolcat
    if ! command -v lolcat >/dev/null 2>&1 || ! pip show lolcat >/dev/null 2>&1; then
        pip install lolcat >/dev/null 2>&1 &
        show_spinner "lolcat(pip)"
    fi

    # Zsh configuration
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh >/dev/null 2>&1 &
        show_spinner "oh-my-zsh"
    fi
    
    # Zsh plugins
    ZSH_PLUGINS_DIR="$HOME/.oh-my-zsh/custom/plugins" # Use custom directory for plugins
    if [ ! -d "$ZSH_PLUGINS_DIR/zsh-autosuggestions" ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_PLUGINS_DIR/zsh-autosuggestions" >/dev/null 2>&1 &
        show_spinner "zsh-autosuggestions"
    fi
    
    if [ ! -d "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting" ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting" >/dev/null 2>&1 &
        show_spinner "zsh-syntax"
    fi
    
    # Ruby lolcat (more features, use both)
    if ! gem list lolcat | grep -q 'lolcat'; then
        echo "y" | gem install lolcat > /dev/null 2>&1 &
        show_spinner "lolcat「Ruby Gem」"
    fi

    # Final Zsh Shell Change
    if [ "$SHELL" != "/data/data/com.termux/files/usr/bin/zsh" ]; then
        chsh -s zsh >/dev/null 2>&1 &
        show_spinner "zsh-shell-change"
    fi
    
    # Remove default Termux MOTD to replace with our banner
    rm -rf /data/data/com.termux/files/usr/etc/motd >/dev/null 2>&1
    
    # Move custom files (Assuming files/ directory is present in CODEX)
    mkdir -p "$HOME/.Codex-simu"
    
    # Create necessary files/folders for the custom scripts
    mv "$HOME/CODEX/files/remove" /data/data/com.termux/files/usr/bin/ 2>/dev/null || true
    chmod +x /data/data/com.termux/files/usr/bin/remove 2>/dev/null || true
    
    if [ ! -f "$HOME/.Codex-simu/report" ]; then
        mv "$HOME/CODEX/files/report" "$HOME/.Codex-simu" 2>/dev/null || true
        # show_spinner "Codex-report" # Skip spinner for internal file move
    fi
    
    if [ ! -f "/data/data/com.termux/files/usr/bin/chat" ]; then
        mv "$HOME/CODEX/files/chat.sh" /data/data/com.termux/files/usr/bin/chat 2>/dev/null || true
        chmod +x /data/data/com.termux/files/usr/bin/chat 2>/dev/null || true
        # show_spinner "chat" # Skip spinner for internal file move
    fi
    
    # Check for storage permission
    if [ ! -d "$HOME/storage/shared" ]; then
        echo -e " ${A} ${g}Requesting Storage Permission...${n}"
        termux-setup-storage
    fi
}

# Configuration of Termux environment and banner files
setup() {
    # dx move
    ds="$HOME/.termux"
    dx="$ds/font.ttf"
    simu="$ds/colors.properties"
    
    mkdir -p "$ds"

    # Copy font and color config (if they don't exist)
    if [ ! -f "$dx" ] && [ -f "$HOME/CODEX/files/font.ttf" ]; then
        cp "$HOME/CODEX/files/font.ttf" "$ds"
    fi

    if [ ! -f "$simu" ] && [ -f "$HOME/CODEX/files/colors.properties" ]; then
        cp "$HOME/CODEX/files/colors.properties" "$ds"
    fi
    
    # Copy custom FIGlet font
    if [ -f "$HOME/CODEX/files/ASCII-Shadow.flf" ]; then
        cp "$HOME/CODEX/files/ASCII-Shadow.flf" "$PREFIX/share/figlet/"
    fi
    
    # Copy custom entry script (if applicable)
    if [ -f "$HOME/CODEX/files/dx-simu.sh" ]; then
        mkdir -p "/data/data/com.termux/files/usr/bin/"
        cp "$HOME/CODEX/files/dx-simu.sh" "/data/data/com.termux/files/usr/bin/dx-simu"
        chmod +x "/data/data/com.termux/files/usr/bin/dx-simu"
    fi
    
    # Reload Termux settings for font/color changes
    if command -v termux-reload-settings &>/dev/null; then
        echo -e " ${A} ${g}Applying Termux theme/font changes...${n}"
        termux-reload-settings
    fi
}

# Network check loop
dxnetcheck() {
    clear
    echo
    echo -e "               ${g}╔═══════════════╗"
    echo -e "               ${g}║ ${n}</>  ${c}CODEX-X${g}  ║"
    echo -e "               ${g}╚═══════════════╝"
    echo -e "  ${g}╔════════════════════════════════════════════╗"
    echo -e "  ${g}║  ${C} ${y}Checking Your Internet Connection¡${g}  ║"
    echo -e "  ${g}╚════════════════════════════════════════════╝${n}"
    while true; do
        curl -s --head --fail https://github.com > /dev/null
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

# User name input and configuration file creation
donotchange() {
    clear
    echo
    echo
    echo -e "${c}              (\_/)"
    echo -e "              (${y}^_^${c})     ${A} ${g}Hey dear${c}"
    echo -e "             ⊂(___)づ  ⋅˚₊‧ ଳ ‧₊˚ ⋅"
    echo
    echo -e " ${A} ${c}Please Enter Your ${g}Banner Name${c}"
    echo

    local name
    # Loop to prompt until valid name (1-8 characters)
    while true; do
        read -p "[+]──[Enter Your Name (1-8 chars)]────► " name
        echo

        # Validate name length (must be 1-8 characters)
        if [[ ${#name} -ge 1 && ${#name} -le 8 ]]; then
            break  # Valid, proceed
        else
            echo -e " ${E} ${r}Name must be between ${g}1 and 8${r} characters. ${y}Please try again.${c}"
            echo
        fi
    done

    # Specify directories and files
    D1="$HOME/.termux"
    USERNAME_FILE="$D1/usernames.txt"
    VERSION="$D1/dx.txt"
    INPUT_ZSHRC_TEMPLATE="$HOME/CODEX/files/.zshrc"
    THEME_INPUT="$HOME/CODEX/files/.codex.zsh-theme"
    OUTPUT_ZSHRC="$HOME/.zshrc"
    OUTPUT_THEME="$HOME/.oh-my-zsh/themes/codex.zsh-theme"
    TEMP_ZSHRC="$HOME/temp.zshrc"

    # Ensure template files exist before proceeding
    if [ ! -f "$INPUT_ZSHRC_TEMPLATE" ] || [ ! -f "$THEME_INPUT" ]; then
        echo -e " ${E} ${r}Error: Essential configuration templates not found in CODEX/files/."
        sleep 3
        return 1
    fi

    # 1. Replace SIMU with the name in .zshrc template and save to temporary file
    sed "s/SIMU/$name/g" "$INPUT_ZSHRC_TEMPLATE" > "$TEMP_ZSHRC" &&
    # 2. Replace SIMU with the name in the theme file and save to Zsh themes folder
    sed "s/SIMU/$name/g" "$THEME_INPUT" > "$OUTPUT_THEME" &&
    # 3. Store the name for future use
    echo "$name" > "$USERNAME_FILE" &&
    # 4. Create placeholder files
    echo "" > "$VERSION" &&
	echo "" > "$D1/ads.txt"

    # Check if all operations were successful
    if [[ $? -eq 0 ]]; then
        # Move the temporary file to the original output
        mv "$TEMP_ZSHRC" "$OUTPUT_ZSHRC"
        
        clear
        echo
        echo
        echo -e "		        ${g}Hey ${y}$name"
        echo -e "${c}              (\_/)"
        echo -e "              (${y}^ω^${c})     ${g}I'm Dx-Simu${c}"
        echo -e "             ⊂(___)づ  ⋅˚₊‧ ଳ ‧₊˚ ⋅"
        echo
        echo -e " ${A} ${c}Your Advanced Banner created ${g}Successfully¡${c}"
        echo
        sleep 3
    else
        echo
        echo -e " ${E} ${r}Error occurred while processing the banner files."
        sleep 1
        # Clean up temporary file if sed fails
        rm -f "$TEMP_ZSHRC"
        return 1
    fi

    echo
    clear
}

# Combined installation function
termux() {
    spin
}

# --- 4. Banner Functions ---

# Basic (pre-install) banner
banner() {
    echo
    echo
    echo -e "   ${y}░█████╗░░█████╗░██████╗░███████╗██╗░░██╗"
    echo -e "   ${y}██╔══██╗██╔══██╗██╔══██╗██╔════╝╚██╗██╔╝"
    echo -e "   ${y}██║░░╚═╝██║░░██║██║░░██║█████╗░░░╚███╔╝░"
    echo -e "   ${c}██║░░██╗██║░░██║██║░░██║██╔══╝░░░██╔██╗░"
    echo -e "   ${c}╚█████╔╝╚█████╔╝██████╔╝███████╗██╔╝╚██╗"
    echo -e "   ${c}░╚════╝░░╚════╝░╚═════╝░╚══════╝╚═╝░░╚═╝${n}"
    echo -e "${y}               +-+-+-+-+-+-+-+-+"
    echo -e "${c}               |D|S|-|C|O|D|E|X|"
    echo -e "${y}               +-+-+-+-+-+-+-+-+${n}"
    echo
    if [ $random_number -eq 0 ]; then
        echo -e "${b}╭════════════════════════⊷"
        echo -e "${b}┃ ${g}[${n}ム${g}] ᴛɢ: ${y}t.me/Termuxcodex"
        echo -e "${b}╰════════════════════════⊷"
    else
        echo -e "${b}╭══════════════════════════⊷"
        echo -e "${b}┃ ${g}[${n}ム${g}] ᴛɢ: ${y}t.me/alphacodex369"
        echo -e "${b}╰══════════════════════════⊷"
    fi
    echo
    echo -e "${b}╭══ ${g}〄 ${y}ᴄᴏᴅᴇx ${g}〄"
    echo -e "${b}┃❁ ${g}ᴄʀᴇᴀᴛᴏʀ: ${y}ᴅx-ᴄᴏᴅᴇx"
    echo -e "${b}┃❁ ${g}ᴅᴇᴠɪᴄᴇ: ${y}${VENDOR} ${MODEL}"
    echo -e "${b}╰┈➤ ${g}Hey ${y}Dear"
    echo
}

# Menu banner (less info than the main banner)
banner2() {
    echo
    echo
    echo -e "   ${y}░█████╗░░█████╗░██████╗░███████╗██╗░░██╗"
    echo -e "   ${y}██╔══██╗██╔══██╗██╔══██╗██╔════╝╚██╗██╔╝"
    echo -e "   ${y}██║░░╚═╝██║░░██║██║░░██║█████╗░░░╚███╔╝░"
    echo -e "   ${c}██║░░██╗██║░░██║██║░░██║██╔══╝░░░██╔██╗░"
    echo -e "   ${c}╚█████╔╝╚█████╔╝██████╔╝███████╗██╔╝╚██╗"
    echo -e "   ${c}░╚════╝░░╚════╝░╚═════╝░╚══════╝╚═╝░░╚═╝${n}"
    echo -e "${y}               +-+-+-+-+-+-+-+-+"
    echo -e "${c}               |D|S|-|C|O|D|E|X|"
    echo -e "${y}               +-+-+-+-+-+-+-+-+${n}"
    echo
    if [ $random_number -eq 0 ]; then
        echo -e "${b}╭════════════════════════⊷"
        echo -e "${b}┃ ${g}[${n}ム${g}] ᴛɢ: ${y}t.me/Termuxcodex"
        echo -e "${b}╰════════════════════════⊷"
    else
        echo -e "${b}╭══════════════════════════⊷"
        echo -e "${b}┃ ${g}[${n}ム${g}] ᴛɢ: ${y}t.me/alphacodex369"
        echo -e "${b}╰══════════════════════════⊷"
    fi
    echo
    echo -e "${b}╭══ ${g}〄 ${y}ᴄᴏᴅᴇx ${g}〄"
    echo -e "${b}┃❁ ${g}ᴄʀᴇᴀᴛᴏʀ: ${y}ᴅx-ᴄᴏᴅᴇx"
    echo -e "${b}╰┈➤ ${g}Hey ${y}Dear"
    echo
    echo -e "${c}╭════════════════════════════════════════════════⊷"
    echo -e "${c}┃ ${p}❏ ${g}Choose what you want to use. then Click Enter${n}"
    echo -e "${c}╰════════════════════════════════════════════════⊷"
}

# --- 5. Main Execution Logic ---

setupx() {
    # Check if we are running on Termux
    if [ -d "/data/data/com.termux/files/usr/" ]; then
        tr # Install initial required tools
        dxnetcheck # Check network
        
        banner
        echo -e " ${C} ${y}Detected Termux on Android¡"
        echo -e " ${lm}"
        echo -e " ${A} ${g}Updating and Installing Advanced Packages...¡"
        echo -e " ${dm}"
        echo -e " ${A} ${g}Wait a few minutes.${n}"
        echo -e " ${lm}"
        termux # Run full installation
        
        # dx check if CODEX folder exists after initial installation steps
        if [ -d "$HOME/CODEX" ]; then
            sleep 2
            clear
            banner
            echo -e " ${A} ${p}Advanced Setup Completed...!¡"
            echo -e " ${dm}"
            
            clear
            banner
            echo -e " ${C} ${c}Configuring Your Termux Environment...${n}"
            echo
            echo -e " ${A} ${g}Wait a few moments.${n}"
            
            setup # Copy config files (fonts, colors, etc.)
            donotchange # Get username and configure Zsh files
            
            # Final message
            clear
            banner
            get_dynamic_info # Show advanced system info
            echo -e " ${g}[${n}${PKGS}${g}] ${y}Status: ${g}Advanced Installation Complete!${n}"
            echo -e " ${C} ${c}Type ${g}exit ${c} or restart Termux to load your new ${y}Zsh Banner¡¡ ${g}[${n}${HOMES}${g}]${n}"
            echo
            sleep 3
            cd "$HOME"
            rm -rf "$HOME/CODEX" 2>/dev/null
            exit 0
        else
            clear
            banner
            echo -e " ${E} ${r}Tools Source Folder (CODEX) Not Found After Install!"
            echo
            sleep 3
            exit
        fi
    else
        clear
        banner
        echo -e " ${E} ${r}Sorry, this operating system is not supported ${p}| ${g}[${n}${HOST}${g}] ${SHELL}${n}"
        echo
        echo -e " ${A} ${g} Waiting for the next update using Linux...!¡"
        echo
        sleep 3
        exit
    fi
}


# --- 6. Interactive Menu ---
start # Initial welcome animation

options=("Free Usage (Advanced Setup)" "Premium")
selected=0
display_menu() {
    clear
    banner2
    echo
    echo -e " ${g}■ \e[4m${p}Select An Option\e[0m ${g}▪︎${n}"
    echo
    for i in "${!options[@]}"; do
        if [ $i -eq $selected ]; then
            echo -e " ${g}〄> ${c}${options[$i]} ${g}<〄${n}"
        else
            echo -e "     ${options[$i]}"
        fi
    done
}

# Main loop
while true; do
    display_menu
    read -rsn1 input # Reads a single character, no echo
    if [[ "$input" == $'\e' ]]; then
        # Arrow key detected (starts with ESC)
        read -rsn2 -t 0.1 input # Read the next two characters
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
            *)
                # Handle other escape sequences
                ;;
        esac
    elif [[ "$input" == "" ]]; then # Enter key
        case ${options[$selected]} in
            "Free Usage (Advanced Setup)")
                echo -e "\n ${g}[${n}${HOMES}${g}] ${c}Continuing with Advanced Free Setup..!${n}"
                sleep 1
                setupx
                ;;
            "Premium")
                echo -e "\n ${g}[${n}${HOST}${g}] ${c}Opening Telegram for Premium Access..!${n}"
                sleep 1
                xdg-open "https://t.me/Codexownerbot"
                cd "$HOME"
                rm -rf "$HOME/CODEX" 2>/dev/null
                exit 0
                ;;
        esac
    fi
done
