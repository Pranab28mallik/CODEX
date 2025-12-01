# -------------------------------------------------------------------------
# 1. ZSH FRAMEWORK AND PLUGIN INITIALIZATION
# -------------------------------------------------------------------------

# Set ZSH framework path
export ZSH=$HOME/.oh-my-zsh

# Set ZSH Theme
ZSH_THEME="codex" # Assumes 'codex.zsh-theme' is installed in $ZSH/themes/

# Define plugins
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

# Source Oh-My-Zsh core
source $ZSH/oh-my-zsh.sh

# Explicitly source plugins if they are custom-installed (Maintains original path style)
# Note: For most OMZ installations, listing them in the plugins array is sufficient.
# We keep explicit sourcing here just in case they are outside the standard OMZ structure.
# Custom plugins often live in $ZSH/custom/plugins
source $HOME/.oh-my-zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null
source $HOME/.oh-my-zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null


# -------------------------------------------------------------------------
# 2. ADVANCED ALIASES (Using eza/lsd, bat, and htop from previous advanced install)
# -------------------------------------------------------------------------

# Modern replacements for ls
alias ls='lsd'
alias la='lsd -lha --blocks size,name' # List all, human-readable, detailed
alias ll='lsd -lha --group-dirs first' # Group directories first

# System/Tool aliases
alias top='htop' # Advanced process viewer
alias cat='bat --paging=never --style=header,grid' # Modern file content viewer
alias edit='nano' # Simple editor alias

# Codex specific aliases (Corrected pathing)
alias dev='bash $HOME/.CODEX/dev'
alias report='bash $HOME/.Codex-simu/report' # Points to the installed report file
alias rd='termux-reload-settings'

# -------------------------------------------------------------------------
# 3. COLOR AND ICON DEFINITIONS
# -------------------------------------------------------------------------

# Directory for custom files
D1="$HOME/.termux"

# Zsh Color codes (using standard Zsh format %F{...} where possible for RPROMPT,
# but keeping original escape codes for the banner script execution)
r='\033[91m' # Red
p='\033[1;95m' # Purple
y='\033[93m' # Yellow
g='\033[92m' # Green
n='\033[0m' # No Color (Reset)
b='\033[94m' # Blue
c='\033[96m' # Cyan

# dx Symbol
X='\033[1;92m[\033[1;00m⎯꯭̽𓆩\033[1;92m]\033[1;96m'
D='\033[1;92m[\033[1;00m〄\033[1;92m]\033[1;93m'
E='\033[1;92m[\033[1;00m×\033[1;92m]\033[1;91m'
A='\033[1;92m[\033[1;00m+\033[1;92m]\033[1;92m'
C='\033[1;92m[\033[1;00m</>\033[1;32m]\033[1;92m'
lm='\033[96m▱▱▱▱▱▱▱▱▱▱▱▱\033[0m〄\033[96m▱▱▱▱▱▱▱▱▱▱▱\033[0m'
dm='\033[93m▱▱▱▱▱▱▱▱▱▱▱▱\033[0m〄\033[93m▱▱▱▱▱▱▱▱▱▱▱\033[0m'

# DX Icons (Nerd Font dependent)
aHELL="\uf489" # Termux/Terminal
USER="\uf007" # User icon
TERMINAL="\ue7a2" # Shell icon
PKGS="\uf8d6" # Packages
UPT="\uf49b" # Uptime
CAL="\uf073" # Calendar

bol='\033[1m'
# Note: bold="${bol}\e[4m" sets bold and underline. Use with caution.
# Using standard Zsh formatting for the prompt is generally better.


# -------------------------------------------------------------------------
# 4. SYSTEM CHECK FUNCTIONS (Refined)
# -------------------------------------------------------------------------

THRESHOLD=90 # Lowered to be more aggressive

# Checks disk usage and reports warning if above threshold
check_disk_usage() {
    local threshold=${1:-$THRESHOLD}
    local total_size used_size disk_usage

    # Get total size, used size, and disk usage percentage
    if command -v df >/dev/null 2>&1; then
        read -r _ total_size used_size _ disk_usage _ <<< "$(df -h "$HOME" | awk 'NR==2 {print $2, $3, $5}')"
        disk_usage=$(echo "$disk_usage" | sed 's/%//g')
    else
        echo -e " ${E} ${r}WARN: ${y}df command not found.${n}"
        return 1
    fi

    if [ "$disk_usage" -ge "$threshold" ]; then
        # Disk full warning icon (Unicode)
        echo -e " ${g}[${n}\uf0a0${g}] ${r}CRITICAL: ${c}Disk Full ${r}${disk_usage}% ${c}| U:${g}${used_size} ${c}of T:${g}${total_size}"
    else
        # Normal disk usage icon (Unicode - e.g., disk/flash drive)
        echo -e " ${g}[${n}\uf0e7${g}] ${c}Disk usage: ${g}${disk_usage}% ${c}| U:${g}${used_size} ${c}of T:${g}${total_size}"
    fi
}

data=$(check_disk_usage)

# Advanced Spinner for update/cloning
spin() {
    local pid=$1
    local delay=0.10
    local spinner=('◒' '◓' '◑' '◔')

    while ps -p $pid > /dev/null 2>/dev/null; do
        for i in "${spinner[@]}"; do
            tput civis
            # Dynamic message and spinner display
            echo -ne "${c}\r [+] Downloading/Updating... ${y}[${g}$i${y}]${n}  "
            sleep $delay
            printf "\b\b\b"
        done
    done
    printf "   \b\b\b\b\b"
    tput cnorm
    printf "${y} [Done!]\e[0m\n"
    echo
    sleep 1
}

# -------------------------------------------------------------------------
# 5. UPDATE CHECK LOGIC
# -------------------------------------------------------------------------

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

VERSION="$D1/dx.txt"
if [[ -n "$(cat "$VERSION" 2>/dev/null)" ]]; then
    version=$(cat "$VERSION")
    banner
    echo -e " ${A} ${c}Tools Updated ${n}| ${c}New ${g}$version"
    sleep 3
    echo "" > "$D1/dx.txt"
    # Execute update clone in background
    git clone https://github.com/Alpha-Codex369/CODEX.git &> /dev/null &
    spin $! # Pass background PID to spin
    cd CODEX 2>/dev/null && bash install.sh
else
    clear
fi

# -------------------------------------------------------------------------
# 6. BANNER DISPLAY AND DRAWING (Advanced Dynamic Box)
# -------------------------------------------------------------------------

load() {
    # Enhanced loading animation
    clear
    echo -e "${TERMINAL}${r}●${n}"
    sleep 0.1
    clear
    echo -e "${TERMINAL}${r}●${y}●${n}"
    sleep 0.1
    clear
    echo -e "${TERMINAL}${r}●${y}●${b}●${n}"
    sleep 0.1
}

# Terminal control functions
PUT() { echo -en "\033[${1};${2}H"; }
HIDECURSOR() { echo -en "\033[?25l"; }
NORM() { echo -en "\033[?12l\033[?25h"; }

HIDECURSOR
load
clear

width=$(tput cols)
height=$(tput lines)
# Ensure minimum width for the banner box
if [ "$width" -lt 60 ]; then
    width=60
fi

# Box drawing variables
var=$((width - 1))
var2=$(printf '═%.0s' $(seq 1 $var)) # Horizontal line
var3=$(printf ' %.0s' $(seq 1 $var)) # Spaces

# --- Calculate placement ---
# Define the coordinates for the box (Top row: 2, Left column: 1)
TOP_ROW=2
BOTTOM_ROW=$((TOP_ROW + 9)) # 10 lines tall box

# Place the simple load prefix and disk usage check above the box
prefix="${TERMINAL}${r}●${y}●${b}●${n}"
clean_prefix=$(echo -e "$prefix" | sed 's/\x1b\[[0-9;]*m//g')
prefix_len=${#clean_prefix}
clean_data=$(echo -e "${data}" | sed 's/\x1b\[[0-9;]*m//g')
data_len=${#clean_data}
data_start=$(((width - data_len) / 2))
padding=$((data_start - prefix_len))
if [ $padding -lt 0 ]; then padding=0; fi
spaces=$(printf '%*s' $padding "")
echo -e "${prefix}${spaces}${data}${c}"

# --- Draw Box ---
PUT $TOP_ROW 1
echo "╔${var2}╗"

for ((i=1; i<=8; i++)); do
    PUT $((TOP_ROW + i)) 1
    echo "║${var3}║"
done

PUT $BOTTOM_ROW 1
echo "╚${var2}╝"

# --- Place Content Inside Box ---

# 1. FIGLET Banner (Line 3, centered)
FIGLET_ROW=$((TOP_ROW + 1))
PUT $FIGLET_ROW 0
figlet -c -f ASCII-Shadow -w $width SIMU | lolcat

# 2. Codex Version/Tag (Line 9, right-aligned)
TAG_ROW=$((TOP_ROW + 7))
CODEX_TAG="[${aHELL}] CODEX 1.4"
TAG_LEN=$(echo -e "$CODEX_TAG" | sed 's/\x1b\[[0-9;]*m//g' | wc -c)
TAG_START=$((width - TAG_LEN - 1))
PUT $TAG_ROW $TAG_START
echo -e "\e[32m${CODEX_TAG}\e[0m"

# 3. Dynamic Ads/Date (Line 10, left-aligned)
INFO_ROW=$((TOP_ROW + 8))
PUT $INFO_ROW 3

ADS="$D1/ads.txt"
if [[ -n "$(cat "$ADS" 2>/dev/null)" ]]; then
    content=$(cat "$ADS")
    echo -e " ${g}[${n}${PKGS}${g}] ${c}Ｃｏｄｅｘ: ${g}$content"
    echo "" > "$D1/ads.txt"
else
    # Fallback/Default Info: Date and Time
    DATE=$(date +"%Y-%b-%a ${g}—${c} %d")
    TM=$(date +"%I:%M:%S ${g}— ${c}%p")
    echo -e " ${g}[${n}${CAL}${g}] ${c}${TM} ${g}| ${c}${DATE}"
fi

# 4. Vertical Separator Bar (for aesthetic)
PUT 3 1
echo -e "\033[36;1m"
for ((i=1; i<=7; i++)); do
    PUT $((TOP_ROW + i)) 1
    echo "║"
done

# --- Final Cleanup ---
PUT $((BOTTOM_ROW + 1)) 1 # Move cursor below the box
NORM # Restore cursor visibility
echo # Print a final newline to separate prompt from banner
