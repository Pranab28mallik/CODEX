#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# Script: CODEX Advanced Termux Setup (v2.0 - Gemini Enhanced)
# Author: DARK-PRINCE (Original Script Base)
# Enhanced: Gemini AI (For P10k, FZF, Robustness, and Dynamic Config)
# Purpose: Installs and configures Termux with ZSH, Powerlevel10k, FZF, 
#          plugins, dynamic colors, and personalized banner.
# =========================================================================

# --- 1. CONFIGURATION AND STYLES ---

PREFIX="/data/data/com.termux/files/usr"
HOME_DIR="$HOME"
TERMUX_DIR="$HOME_DIR/.termux"
P10K_DIR="$HOME_DIR/powerlevel10k" # Dedicated P10k Directory
ZSH_PLUGINS_DIR="$HOME_DIR/.oh-my-zsh/custom/plugins"
CODEX_TEMP_DIR="$HOME_DIR/.codex_temp"

# Colors and Styling (Standard ANSI)
R='\033[1;91m' # Red
P='\033[1;95m' # Purple
Y='\033[1;93m' # Yellow
G='\033[1;92m' # Green
N='\033[0m'    # Reset
B='\033[1;94m' # Blue
C='\033[1;96m' # Cyan

SYMBOL_OK="${G}[${N}✓${G}]${C}"
SYMBOL_ERR="${R}[${N}✗${R}]${R}"
SYMBOL_INFO="${B}[${N}i${B}]${C}"
SYMBOL_ARROW="${C}[${N}»${C}]${G}"
SYMBOL_LINE="${C}====================================================${N}"

# System/Device Info
MODEL_NAME=$(getprop ro.product.model 2>/dev/null || echo "Android Device")
DEVICE_INFO="${MODEL_NAME}"

# --- 2. CORE UTILITY FUNCTIONS ---

# Function to safely exit and cleanup
exit_script() {
    clear
    echo -e "\n${SYMBOL_LINE}"
    echo -e "${C}              (\_/)"
    echo -e "              (${Y}^_^${C})     ${SYMBOL_OK} ${G}Setup Finalized${C}"
    echo -e "             ⊂(___)づ  ⋅˚₊‧ ଳ ‧₊˚ ⋅"
    echo -e "${SYMBOL_LINE}"
    echo -e "\n ${SYMBOL_INFO} ${C}Exiting ${G}Advanced Termux Setup...${N}"
    
    # Clean up temporary directory
    rm -rf "$CODEX_TEMP_DIR" >/dev/null 2>&1
    
    echo -e "${SYMBOL_INFO} ${C}Cleanup complete. Restart Termux!${N}\n"
    cd "$HOME_DIR"
    exit 0
}

# Trap signals for graceful exit
trap exit_script SIGINT SIGTSTP

# Function for advanced type-effect animation
type_effect_advanced() {
    local text="$1"
    local delay=${2:-0.04}
    local LIME='\e[38;5;154m'
    local NC='\e[0m'
    local term_width=$(tput cols 2>/dev/null || echo 80)
    local text_length=${#text}
    local padding=$(( (term_width - text_length) / 2 ))
    
    printf "%${padding}s" ""
    for ((i=0; i<${#text}; i++)); do
        printf "${LIME}${text:$i:1}${NC}"
        sleep "$delay"
    done
    echo
}

# Function for package installation with robust checks and spinner
install_spinner() {
    local package_name=$1
    local install_cmd=$2
    local delay=0.1
    local spinner=('◒' '◐' '◓' '◑')
    local pid

    # Check for core packages (using dpkg-l)
    if [[ "$package_name" != *"(pip)" && "$package_name" != *"(gem)" ]]; then
        if dpkg -l | grep -q "^ii  $package_name " >/dev/null 2>&1; then
            echo -e "${SYMBOL_OK} ${Y}$package_name${C} already installed. Skipping.${N}"
            return 0
        fi
    fi

    # Run installation command in background
    (eval "$install_cmd") >"$CODEX_TEMP_DIR/install.log" 2>&1 &
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
        echo -e "\r ${SYMBOL_ERR} ${R}Failed to install ${Y}$package_name${R}. See log in $CODEX_TEMP_DIR.${N} "
    fi
}

# --- 3. ANIMATION AND BANNERS ---

# Main Setup Banner (Clean and Advanced)
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
    echo -e "${C}               ADVANCED TERMUX SETUP"
    echo -e "${Y}               +-+-+-+-+-+-+-+-+${N}"
    echo
    echo -e "${B}╭══ ${G}〄 ${Y}TERMINAL-SIMULATION ${G}〄"
    echo -e "${B}┃❁ ${G}ᴅᴇᴠɪᴄᴇ: ${Y}${DEVICE_INFO}"
    echo -e "${B}╰┈➤ ${G}Status: ${C}Running Setup...${N}"
    echo
}

# --- 4. INSTALLATION AND SETUP FUNCTIONS ---

# Core dependency installation and check
install_dependencies() {
    main_banner
    echo -e " ${SYMBOL_LINE}"
    echo -e " ${SYMBOL_INFO} ${G}Performing initial checks and updates...${N}"
    echo -e " ${SYMBOL_LINE}"
    
    # Ensure temporary directory exists
    mkdir -p "$CODEX_TEMP_DIR"
    
    # Initial Update/Upgrade
    install_spinner "System Update/Upgrade" "apt update -y && apt upgrade -y"
    
    # Array of essential packages
    declare -A packages=(
        ["curl"]="pkg install curl -y"
        ["git"]="pkg install git -y"
        ["python"]="pkg install python -y"
        ["zsh"]="pkg install zsh -y"
        ["ruby"]="pkg install ruby -y"
        ["figlet"]="pkg install figlet -y"
        ["fzf"]="pkg install fzf -y" # Fuzzy finder for ZSH
        ["termux-api"]="pkg install termux-api -y"
        ["lolcat(pip)"]="pip install lolcat"
        ["figlet-fonts"]="pkg install figlet-fonts -y"
        ["wget"]="pkg install wget -y" # Added for robustness
    )

    for package in "${!packages[@]}"; do
        install_spinner "$package" "${packages[$package]}"
    done

    echo -e "\n ${SYMBOL_LINE}"
    echo -e " ${SYMBOL_OK} ${G}All dependencies checked/installed.${N}"
    echo -e " ${SYMBOL_LINE}\n"
}

# ZSH and Advanced Theme/Plugin Setup
setup_zsh_advanced() {
    main_banner
    echo -e " ${SYMBOL_LINE}"
    echo -e " ${SYMBOL_INFO} ${G}Setting up ZSH, Oh My Zsh, and Powerlevel10k...${N}"
    echo -e " ${SYMBOL_LINE}"

    # 1. Oh My Zsh Clone
    if [ ! -d "$HOME_DIR/.oh-my-zsh" ]; then
        install_spinner "Oh-My-Zsh" "git clone https://github.com/ohmyzsh/ohmyzsh.git $HOME_DIR/.oh-my-zsh"
    else
        echo -e "${SYMBOL_OK} ${Y}Oh-My-Zsh${C} directory found. Skipping clone.${N}"
    fi
    
    # 2. Powerlevel10k Clone (Best ZSH Theme)
    if [ ! -d "$P10K_DIR" ]; then
        install_spinner "Powerlevel10k" "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $P10K_DIR"
    else
        echo -e "${SYMBOL_OK} ${Y}Powerlevel10k${C} found. Skipping clone.${N}"
    fi

    # 3. Plugins Clone (Autosuggestions & Syntax Highlighting)
    mkdir -p "$ZSH_PLUGINS_DIR"
    if [ ! -d "$ZSH_PLUGINS_DIR/zsh-autosuggestions" ]; then
        install_spinner "zsh-autosuggestions" "git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_PLUGINS_DIR/zsh-autosuggestions"
    else
        echo -e "${SYMBOL_OK} ${Y}zsh-autosuggestions${C} found. Skipping clone.${N}"
    fi

    if [ ! -d "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting" ]; then
        install_spinner "zsh-syntax-highlighting" "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_PLUGINS_DIR/zsh-syntax-highlighting"
    else
        echo -e "${SYMBOL_OK} ${Y}zsh-syntax-highlighting${C} found. Skipping clone.${N}"
    fi
    
    # 4. ZSH Shell Change
    if [ "$SHELL" != "$PREFIX/bin/zsh" ]; then
        install_spinner "ZSH Shell Change" "chsh -s $PREFIX/bin/zsh"
    else
        echo -e "${SYMBOL_OK} ${Y}ZSH${C} is already the default shell.${N}"
    fi
    
    # 5. Cleanup MOTD
    if [ -f "$PREFIX/etc/motd" ]; then
        rm -f "$PREFIX/etc/motd" >/dev/null 2>&1
    fi
    
    echo -e "\n ${SYMBOL_LINE}"
    echo -e " ${SYMBOL_OK} ${G}ZSH setup complete.${N}"
    echo -e " ${SYMBOL_LINE}\n"
}

# Final Termux Configuration and ZSHRC/P10K Customization (DYNAMIC GENERATION)
set_personalized_banner_and_config() {
    clear
    echo
    echo
    echo -e "${C}              (\_/)"
    echo -e "              (${Y}^_^${C})     ${SYMBOL_OK} ${G}Hey dear${C}"
    echo -e "             ⊂(___)づ  ⋅˚₊‧ ଳ ‧₊˚ ⋅"
    echo
    echo -e " ${SYMBOL_ARROW} ${C}Please Enter Your ${G}Banner Name${C}"
    echo

    local name
    
    # Loop to prompt until valid name (1-12 characters)
    while true; do
        read -rp "[+]──[Enter Your Name (1-12 chars)]────► " name
        echo

        # Input validation
        if [[ ${#name} -ge 1 && ${#name} -le 12 && "$name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
            break  # Valid, proceed
        else
            echo -e " ${SYMBOL_ERR} ${R}Name must be ${G}1-12 characters${R} (A-Z, 0-9, _, - only). ${Y}Please try again.${N}"
            echo
        fi
    done

    echo -e "\n ${SYMBOL_INFO} ${C}Generating dynamic ZSH configuration...${N}"

    # --- ZSHRC FILE GENERATION (Advanced) ---
    
    # Create the advanced .zshrc file
cat << EOF > "$HOME_DIR/.zshrc"
# =========================================================================
# Custom ZSH Configuration - Generated by Gemini AI
# Based on Termux, Oh My Zsh, Powerlevel10k, FZF, and custom banner
# =========================================================================

# --- PATH & Shell Initialization ---
export TERM="xterm-256color"
export PATH="\$HOME/.local/bin:\$PATH"
export ZSH="\$HOME/.oh-my-zsh"

# --- ZSH Theme & Plugins ---
ZSH_THEME="powerlevel10k/powerlevel10k" # Use Powerlevel10k

# Essential Plugins: git (OMZ default), zsh-autosuggestions, zsh-syntax-highlighting, fzf
plugins=(git zsh-autosuggestions zsh-syntax-highlighting fzf)

source \$ZSH/oh-my-zsh.sh

# --- Custom Termux/Environment Setup ---
# Fix for P10k prompt issues in some terminals
[[ ! -r "\$P10K_DIR/gitstatus.powerlevel10k" ]] || source "\$P10K_DIR/gitstatus.powerlevel10k"

# ZSH Alias and Function Overrides
alias ls='lsd'
alias ll='lsd -al'
alias la='lsd -a'
alias update='pkg update -y && pkg upgrade -y'
alias cleanup='pkg clean'
alias t-api='termux-open-url'
# Better navigation
alias ..='cd ..'
alias ...='cd ../..'

# --- FZF Configuration ---
# Set up fzf key bindings and completion
[ -f \$PREFIX/share/fzf/key-bindings.zsh ] && source \$PREFIX/share/fzf/key-bindings.zsh
[ -f \$PREFIX/share/fzf/completion.zsh ] && source \$PREFIX/share/fzf/completion.zsh

# --- Powerlevel10k Configuration ---
# To customize the prompt, run 'p10k configure'
[[ -f \$HOME_DIR/.p10k.zsh ]] && source \$HOME_DIR/.p10k.zsh

# --- Dynamic Banner Function ---
codex_banner() {
    clear
    figlet -f ASCII-Shadow "${name}" | lolcat
    echo -e "\${G}   Welcome Back, \${Y}${name}\${G}! \${C}Device: \${Y}${DEVICE_INFO}\${N}"
    echo -e "\${G}   ZSH Status: \${C}Powerlevel10k Ready. Run \${Y}p10k configure\${C} for customization.\${N}"
    echo -e "\${G}   Type \${Y}help \${G}for common aliases.\${N}"
    echo
}

# Run the banner on shell start (or 'clear' if you prefer a clean start)
codex_banner

# --- Final Message/Cleanup (Optional) ---
# Check for a new Termux session to run banner only once per new window
if [ -n "\$TERMUX_VERSION" ]; then
    # Clear and show banner only on first run or new session
    if [ ! -f "\$TERMUX_DIR/.zsh_session_start" ]; then
        touch "\$TERMUX_DIR/.zsh_session_start"
    fi
fi
EOF

    # --- P10k Configuration File Generation (Basic Setup) ---
    # Create a basic .p10k.zsh file to prevent errors on first run
    # User will be prompted to run 'p10k configure' manually.
    if [ ! -f "$HOME_DIR/.p10k.zsh" ]; then
        echo -e "${SYMBOL_INFO} ${C}Creating placeholder ${Y}.p10k.zsh${C} file. Run ${G}p10k configure${C} later.${N}"
        cp "$P10K_DIR/config/p10k-lean.zsh" "$HOME_DIR/.p10k.zsh" 2>/dev/null || true
    fi
    
    # --- Final Customization Files ---
    mkdir -p "$TERMUX_DIR"
    # Note: Fonts and colors files are generally required externally or via Termux-Styling app. 
    # I'll create a basic properties file to reduce dependency on external files.
    
cat << EOF > "$TERMUX_DIR/colors.properties"
# Advanced Codex Color Scheme (v2.0)
background=#000000
foreground=#FFFFFF
color0=#1C1C1C
color1=#CC0000
color2=#4E9A06
color3=#C4A000
color4=#3465A4
color5=#75507B
color6=#06989A
color7=#D3D7CF
color8=#555753
color9=#EF2929
color10=#8AE234
color11=#FCE94F
color12=#729FCF
color13=#AD7FA8
color14=#34E2E2
color15=#EEEEEE
EOF

    echo -e "${SYMBOL_INFO} ${C}Reloading Termux settings... (Requires Termux-API)${N}"
    termux-reload-settings 2>/dev/null || echo -e "${SYMBOL_WARN} ${Y}Could not reload settings. Restart Termux manually.${N}"

    # Final success message
    clear
    echo
    echo
    echo -e "		        ${G}Hey ${Y}$name"
    echo -e "${C}              (\_/)"
    echo -e "              (${Y}^ω^${C})     ${G}I'm Dx-Simu${C}"
    echo -e "             ⊂(___)づ  ⋅˚₊‧ ଳ ‧₊˚ ⋅"
    echo
    echo -e " ${SYMBOL_OK} ${C}Your Advanced Setup created ${G}Successfully!${C}"
    echo -e " ${SYMBOL_ARROW} ${G}Configuration complete.${C} Starting new ZSH session.${N}"
    sleep 3
}

# Robust Internet Check
dxnetcheck() {
    clear
    main_banner
    echo -e "  ${G}╔════════════════════════════════════════════╗"
    echo -e "  ${G}║  ${SYMBOL_INFO} ${Y}Checking Your Internet Connection...${G} ║"
    echo -e "  ${G}╚════════════════════════════════════════════╝${N}"
    
    # Ensure curl is available for checking
    if ! command -v curl &>/dev/null; then
        pkg install curl -y >/dev/null 2>&1
        if [ $? -ne 0 ]; then
             echo -e " ${SYMBOL_ERR} ${R}Cannot install Curl. Proceeding without network check.${N}"
             return 0 # Allow script to continue with warning
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
        exit 1
    fi

    # 2. Network Check
    dxnetcheck
    
    # 3. Installation Steps
    install_dependencies
    setup_zsh_advanced
    set_personalized_banner_and_config

    # 4. Final Exit
    clear
    main_banner
    echo -e " ${SYMBOL_OK} ${G}SETUP COMPLETE!${N}"
    echo -e " ${SYMBOL_ARROW} ${C}Type ${G}exit${C} (or restart Termux) to launch your new environment.${N}"
    echo -e " ${SYMBOL_ARROW} ${C}After restart, run: ${G}p10k configure${C} to customize your prompt.${N}"
    
    sleep 5
    exit 0 # Exit successfully after cleanup
}


# --- 5. SCRIPT EXECUTION START POINT ---

# 1. Show opening animation
clear
echo
type_effect_advanced "[ ＡＤＶＡＮＣＥＤ  ＴＥＲＭＵＸ  ＳＥＴＵＰ ]" 0.03
sleep 0.5
type_effect_advanced "「INITIALIZING ENHANCED ENVIRONMENT」" 0.06
sleep 1
clear

# 2. Start the main setup
core_setup_logic
