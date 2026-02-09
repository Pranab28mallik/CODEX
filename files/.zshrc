# Set theme and plugins
ZSH_THEME="codex"
export ZSH="$HOME/.oh-my-zsh"
plugins=(git)

# Source Oh My Zsh and plugins
source "$HOME/.oh-my-zsh/oh-my-zsh.sh"
source "/data/data/com.termux/files/home/.oh-my-zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "/data/data/com.termux/files/home/.oh-my-zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# Aliases for commands
alias ls='lsd'
alias simu='gemini_run'
alias rd='termux-reload-settings'
alias chat='/data/data/com.termux/files/home/.toolx/chat'
alias dev='/data/data/com.termux/files/home/.toolx/dev'
alias report='/data/data/com.termux/files/home/.toolx/dev'
alias update='/data/data/com.termux/files/home/.toolx/update'
alias bname='/data/data/com.termux/files/home/.toolx/bname'
alias help='/data/data/com.termux/files/home/.toolx/help'

# Clear the terminal
clear

# Color codes for styling
r='\033[91m'   # Red
p='\033[1;95m' # Purple
y='\033[93m'   # Yellow
g='\033[92m'   # Green
n='\033[0m'    # Reset
b='\033[94m'   # Blue
c='\033[96m'   # Cyan

# Special symbols with colors
X='\033[1;92m[\033[1;00m⎯꯭̽𓆩\033[1;92m]\033[1;96m'
D='\033[1;92m[\033[1;00m〄\033[1;92m]\033[1;93m'
E='\033[1;92m[\033[1;00m×\033[1;92m]\033[1;91m'
A='\033[1;92m[\033[1;00m+\033[1;92m]\033[1;92m'
C='\033[1;92m[\033[1;00m</>\033[1;32m]\033[1;92m'

# Progress bar symbols
lm='\033[96m▱▱▱▱▱▱▱▱▱▱▱▱\033[0m〄\033[96m▱▱▱▱▱▱▱▱▱▱▱▱\033[1;00m'
dm='\033[93m▱▱▱▱▱▱▱▱▱▱▱▱\033[0m〄\033[93m▱▱▱▱▱▱▱▱▱▱▱▱\033[1;00m'

# Icons for display
aHELL="\uf489"
USER="\uf007"
TERMINAL="\ue7a2"
PKGS="\uf8d6"
UPT="\uf49b"
CAL="\uf073"

# Threshold for disk usage warning
THRESHOLD=100

# Function to check disk usage
check_disk_usage() {
    local threshold=${1:-$THRESHOLD}
    local total_size=$(df -h "$HOME" | awk 'NR==2 {print $2}')
    local used_size=$(df -h "$HOME" | awk 'NR==2 {print $3}')
    local disk_usage=$(df "$HOME" | awk 'NR==2 {print $5}' | sed 's/%//g')

    if [ "$disk_usage" -ge "$threshold" ]; then
        echo -e " ${g}[${n}\uf0a0${g}] ${r}WARN: ${c}Disk Full ${g}${disk_usage}% ${c}| U:${g}${used_size}${c} of T:${g}${total_size}"
    else
        echo -e " ${g}[${n}\uf0e7${g}] ${c}Disk usage: ${g}${disk_usage}% ${c}| U:${g}${used_size}${c} of T:${g}${total_size}"
    fi
}

# Run disk usage check
data=$(check_disk_usage)

# Function for animated spinner
spin() {
    clear
    banner
    local pid=$!
    local delay=0.40
    local spinner=('█■■■■' '■█■■■' '■■█■■' '■■■█■' '■■■■█')

    while ps -p $pid > /dev/null; do
        for i in "${spinner[@]}"; do
            tput civis
            echo -ne "\033[1;96m\r [+] Downloading...please wait [\033[1;92m$i\033[1;93m]\033[0m "
            sleep $delay
            printf "\b\b\b\b\b\b\b\b"
        done
    done
    printf "   \b\b\b\b\b"
    tput cnorm
    printf "\e[1;93m [Done]\e[0m\n"
    sleep 1
}

# URL for server
CODEX="https://codex-server-86mr.onrender.com"
cd "$HOME"
D1=".termux"
VERSION="$D1/dx.txt"

# Check or create version file
if [ -f "$VERSION" ]; then
    version=$(cat "$VERSION")
else
    echo "version 1 1.5" > "$VERSION"
    version=$(cat "$VERSION")
fi

# Banner display
banner() {
    clear
    echo
    echo -e "    ${y}░█████╗░░█████╗░██████╗░███████╗██╗░░██╗"
    echo -e "    ${y}██╔══██╗██╔══██╗██╔══██╗██╔════╝╚██╗██╔╝"
    echo -e "    ${y}██║░░╚═╝██║░░██║██║░░██║█████╗░░░╚███╔╝░"
    echo -e "    ${c}██║░░██╗██║░░██║██║░░██║██╔══╝░░░██╔██╗░"
    echo -e "    ${c}╚█████╔╝╚█████╔╝██████╔╝███████╗██╔╝╚██╗"
    echo -e "    ${c}░╚════╝░░╚════╝░╚═════╝░╚══════╝╚═╝░░╚═╝${n}"
    echo
}

# Function to check for updates
udp() {
    messages=$(curl -s "$CODEX/check_version" | jq -r --arg vs "$version" '.[] | select(.message == $vs) | .message')
    if [ -n "$messages" ]; then
        banner
        echo -e " ${A} ${c}Tools Updated ${n}| ${c}New ${g}$messages"
        sleep 3
        git clone https://github.com/Alpha-Codex369/CODEX.git &> /dev/null &
        spin
        cd CODEX
        bash install.sh
    else
        clear
    fi
}

# Loading animation
load() {
    clear
    echo -e "${TERMINAL}${r}●${n}"
    sleep 0.2
    clear
    echo -e "${TERMINAL}${r}●${y}●${n}"
    sleep 0.2
    clear
    echo -e "${TERMINAL}${r}●${y}●${b}●${n}"
    sleep 0.2
}

# Dynamic width for UI
widths=$(stty size | awk '{print $2}')
width=$(tput cols)
var=$((width - 1))
var2=$(seq -s═ ${var} | tr -d '[:digit:]')
var3=$(seq -s\  ${var} | tr -d '[:digit:]')
var4=$((width - 20))

# Utility functions for drawing UI
PUT() { echo -en "\033[${1};${2}H"; }
DRAW() { echo -en "\033%"; }
WRITE() { echo -en "\033(B"; }
HIDECURSOR() { echo -en "\033[?25l"; }
NORM() { echo -en "\033[?12l\033[?25h"; }

# Run initial functions
udp
HIDECURSOR
load
clear

# Centered display with dynamic width
prefix="${TERMINAL}${r}●${y}●${b}●${n}"
clean_prefix=$(echo -e "$prefix" | sed 's/\x1b\[[0-9;]*m//g')
prefix_len=${#clean_prefix}
clean_data=$(echo -e "${data}" | sed 's/\x1b\[[0-9;]*m//g')
data_len=${#clean_data}
data_start=$(((width - data_len) / 2))
padding=$((data_start - prefix_len))
if [ $padding -lt 0 ]; then padding=0; fi
spaces=$(printf '%*s' "$padding" "")
echo -e "${prefix}${spaces}${data}${c}"

# Draw border box
echo "╔${var2}╗"
for ((i=1; i<=8; i++)); do
    echo "║${var3}║"
done
echo "╚${var2}╝"

# Banner with ASCII art
PUT 4 0
figlet -c -f ASCII-Shadow -w "$width" D1D4X | lolcat
PUT 3 0

# Status info
echo -e "\033[36;1m"
for ((i=1; i<=7; i++)); do
    echo "║"
done
PUT 10 ${var4}
echo -e "\e[32m[\e[0m\uf489\e[32m] \e[36mCODEX \e[36m1 1.4\e[0m"

# Display dynamic message or ads
PUT 12 0
ads1=$(curl -s "$CODEX/ads" | jq -r '.[] | .message')

if [ -z "$ads1" ]; then
    DATE=$(date +"%Y-%b-%a ${g}—${c} %d")
    TM=$(date +"%I:%M:%S ${g}— ${c}%p")
    echo -e " ${g}[${n}${CAL}${g}] ${c}${TM} ${g}| ${c}${DATE}"
else
    echo -e " ${g}[${n}${PKGS}${g}] ${c}Ｃｏｄｅｘ: ${g}$ads1"
fi

NORM
