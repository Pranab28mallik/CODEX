#!/usr/bin/env bash
# Cleaned and fixed install script for CODEX
# Restores single definitions, fixes duplicated sections and robustly handles Termux vs other Linux.
set -u

# -------------------------
# Colors / Icons / Helpers
# -------------------------
r='\033[1;91m'   # red
p='\033[1;95m'   # purple/pink
y='\033[1;93m'   # yellow
g='\033[1;92m'   # green
n='\033[1;0m'    # reset / normal
b='\033[1;94m'   # blue
c='\033[1;96m'   # cyan

# 256-color examples (for terminals that support it)
col_a='\033[38;5;202m' # orange-ish
col_b='\033[38;5;82m'  # lime green
col_c='\033[38;5;99m'  # pinkish
col_d='\033[38;5;45m'  # teal
col_e='\033[38;5;226m' # bright yellow

X='\033[1;92m[\033[1;00m⎯꯭̽𓆩\033[1;92m]\033[1;96m'
A='\033[1;92m[\033[1;00m+\033[1;92m]\033[1;92m'
E='\033[1;92m[\033[1;00m×\033[1;92m]\033[1;91m'
C='\033[1;92m[\033[1;00m</>\033[1;92m]\033[92m'

lm='\033[96m▱▱▱▱▱▱▱▱▱▱▱▱\033[0m〄\033[96m▱▱▱▱▱▱▱▱▱▱▱▱\033[1;00m'
dm='\033[93m▱▱▱▱▱▱▱▱▱▱▱▱\033[0m〄\033[93m▱▱▱▱▱▱▱▱▱▱▱▱\033[1;00m'

HOST_ICON="\uf6c3"
HOMES="\uf015"

# Termux prefixes and detection
PREFIX=${PREFIX:-/data/data/com.termux/files/usr}
IS_TERMUX=false
if [ -d "/data/data/com.termux" ] || [ -d "$PREFIX" ]; then
    IS_TERMUX=true
fi

# Try to read device info on Android; otherwise leave blank
MODEL="$(command -v getprop >/dev/null 2>&1 && getprop ro.product.model 2>/dev/null || echo "Unknown")"
VENDOR="$(command -v getprop >/dev/null 2>&1 && getprop ro.product.manufacturer 2>/dev/null || echo "Unknown")"

random_number=$(( RANDOM % 2 ))
THRESHOLD=90

# -------------------------
# Utility functions
# -------------------------
ce() {
    # color echo: ce <color> <text...>
    local color="$1"; shift
    echo -e "${color}${*}${n}"
}

exit_script() {
    clear
    echo
    ce "${c}" "              (\_/)"
    ce "${y}" "              (^_^)"
    ce "${g}" "             ⊂(___)づ  Exiting Codex Installer"
    echo
    cd "${HOME:-/root}" || true
    # Only remove CODEX dir if it exists and it's inside HOME
    if [ -d "${HOME:-/root}/CODEX" ]; then
        rm -rf "${HOME:-/root}/CODEX"
    fi
    exit 0
}

trap exit_script SIGINT SIGTERM SIGTSTP

check_disk_usage() {
    local threshold=${1:-$THRESHOLD}
    if ! df_out=$(df -h "$HOME" 2>/dev/null | awk 'NR==2'); then
        echo ""
        return
    fi
    local total_size used_size disk_usage
    total_size=$(echo "$df_out" | awk '{print $2}')
    used_size=$(echo "$df_out" | awk '{print $3}')
    disk_usage=$(df "$HOME" 2>/dev/null | awk 'NR==2 {print $5}' | sed 's/%//g' || echo "0")
    if [ -n "$disk_usage" ] && [ "$disk_usage" -ge "$threshold" ]; then
        echo -e "${g}[${n}\uf0a0${g}] ${r}WARN: ${col_a}Disk Full ${g}${disk_usage}% ${c}| ${c}U${g}${used_size} ${c}of ${c}T${g}${total_size}"
    else
        echo -e "${o:-$y}Disk usage:${col_b} ${disk_usage}% ${n}| ${col_c}${used_size}"
    fi
}

sp() {
    # simple typewriter effect: sp "text" [delay]
    local sentence="${1:-}"
    local second="${2:-0.05}"
    local i char
    for (( i=0; i<${#sentence}; i++ )); do
        char=${sentence:$i:1}
        printf "%s" "$char"
        sleep "$second"
    done
    echo
}

# -------------------------
# Visual start banner
# -------------------------
type_effect_centered() {
    local text="$1"
    local delay="$2"
    local term_width
    term_width=$(tput cols 2>/dev/null || echo 80)
    local text_length=${#text}
    local padding=$(( (term_width - text_length) / 2 ))
    printf "%${padding}s" ""
    local colors=("${col_b}" "${col_d}" "${col_c}" "${col_a}" "${col_e}" "${p}" "${b}")
    local i ch col
    for ((i=0; i<${#text}; i++)); do
        ch="${text:$i:1}"
        col="${colors[$((i % ${#colors[@]}))]}"
        printf "${col}%s${n}" "$ch"
        if (( RANDOM % 6 == 0 )); then
            sleep 0.2
        fi
        sleep "$delay"
    done
    echo
}

start() {
    clear
    echo
    type_effect_centered "[ DARK-CODEX STARTED]" 0.04
    sleep 0.4
    type_effect_centered "「HELLO DEAR USER'S DARK GANG 」" 0.06
    sleep 0.8
    type_effect_centered "【DARK-CODEX WILL PROTECT YOU】" 0.06
    sleep 0.8
    clear
}
start

mkdir -p "$HOME/.Codex-Dark" 2>/dev/null || true

# -------------------------
# Package / environment helpers
# -------------------------
ensure_cmd() {
    # ensure_cmd <command> <install-via-pkg-name>
    local cmd="$1"; shift
    local pkgname="${1:-$cmd}"
    if ! command -v "$cmd" >/dev/null 2>&1; then
        if command -v pkg >/dev/null 2>&1; then
            pkg install -y "$pkgname" >/dev/null 2>&1 || true
        elif command -v apt-get >/dev/null 2>&1; then
            apt-get update -qq >/dev/null 2>&1 || true
            apt-get install -y "$pkgname" >/dev/null 2>&1 || true
        fi
    fi
}

tr_setup() {
    ensure_cmd curl curl
    # ncurses-utils maybe named ncurses-utils or ncurses-bin depending on system
    if ! command -v tput >/dev/null 2>&1; then
        ensure_cmd ncurses-utils ncurses-utils || ensure_cmd ncurses-bin ncurses-bin || true
    fi
}

# -------------------------
# Help prompt
# -------------------------
help_prompt() {
    clear
    ce "${p}" "■ \e[4m${g}Use Button\e[4m ${p}▪︎"
    echo
    ce "${y}" "Use Termux Extra key Button"
    echo
    ce "${col_b}" " UP          ↑"
    ce "${col_b}" " DOWN        ↓"
    echo
    ce "${g}" "Press Dark-Gang then Enter"
    echo
    ce "${b}" "■ \e[4m${c}If you understand, press Enter\e[4m ${b}▪︎"
    read -r -p "" _
}

help_prompt

# -------------------------
# Spinner + package installer
# -------------------------
show_spinner_for() {
    # show_spinner_for <pid> <label>
    local pid=$1
    local label="${2:-working}"
    local delay=0.12
    local spinner=('●' '○' '◐' '◒')
    local i
    while kill -0 "$pid" >/dev/null 2>&1; do
        for i in "${spinner[@]}"; do
            printf "\r${col_b} [+] Installing ${label} ${col_e}${i}${n}"
            sleep "$delay"
        done
    done
    printf "\r${col_b} [+] Installed %s ${n}\n" "$label"
}

install_packages() {
    # update/upgrade quietly
    if command -v apt-get >/dev/null 2>&1; then
        apt-get update -qq >/dev/null 2>&1 || true
        apt-get upgrade -y -qq >/dev/null 2>&1 || true
    elif command -v pkg >/dev/null 2>&1; then
        pkg update -y >/dev/null 2>&1 || true
    fi

    packages=(git python ncurses-utils jq figlet termux-api lsd zsh ruby exa)
    for package in "${packages[@]}"; do
        if command -v dpkg >/dev/null 2>&1; then
            if ! dpkg -l 2>/dev/null | grep -q "^ii  $package " ; then
                # use pkg if available, otherwise apt-get
                if command -v pkg >/dev/null 2>&1; then
                    (pkg install -y "$package" >/dev/null 2>&1) &
                    show_spinner_for $! "$package"
                else
                    (apt-get install -y "$package" >/dev/null 2>&1) &
                    show_spinner_for $! "$package"
                fi
            fi
        else
            # No dpkg (e.g. non-debian); attempt install via pkg/apt-get if present
            if command -v pkg >/dev/null 2>&1; then
                (pkg install -y "$package" >/dev/null 2>&1) &
                show_spinner_for $! "$package"
            elif command -v apt-get >/dev/null 2>&1; then
                (apt-get install -y "$package" >/dev/null 2>&1) &
                show_spinner_for $! "$package"
            fi
        fi
    done

    # Install lolcat via gem or pip if missing
    if ! command -v lolcat >/dev/null 2>&1; then
        if command -v gem >/dev/null 2>&1; then
            (gem install lolcat >/dev/null 2>&1) &
            show_spinner_for $! "lolcat(gem)"
        elif command -v pip >/dev/null 2>&1 || command -v pip3 >/dev/null 2>&1; then
            (python -m pip install lolcat >/dev/null 2>&1 || python3 -m pip install lolcat >/dev/null 2>&1) &
            show_spinner_for $! "lolcat(pip)"
        fi
    fi
}

# -------------------------
# Setup files and move assets
# -------------------------
setup_assets() {
    local termux_dir="$HOME/.termux"
    mkdir -p "$termux_dir" 2>/dev/null || true

    # copy font and colors if present in repo files path
    if [ -f "$HOME/CODEX/files/font.ttf" ]; then
        cp -f "$HOME/CODEX/files/font.ttf" "$termux_dir/" 2>/dev/null || true
    fi
    if [ -f "$HOME/CODEX/files/colors.properties" ]; then
        cp -f "$HOME/CODEX/files/colors.properties" "$termux_dir/" 2>/dev/null || true
    fi

    # figlet font
    if [ -f "$HOME/CODEX/files/ASCII-Shadow.flf" ] && [ -d "${PREFIX}/share/figlet" ]; then
        cp -f "$HOME/CODEX/files/ASCII-Shadow.flf" "${PREFIX}/share/figlet/" 2>/dev/null || true
    fi

    # move helper scripts if present
    if [ -f "$HOME/CODEX/files/remove" ]; then
        if [ -w "${PREFIX}/bin" ]; then
            mv -f "$HOME/CODEX/files/remove" "${PREFIX}/bin/" 2>/dev/null || cp -f "$HOME/CODEX/files/remove" "${PREFIX}/bin/" 2>/dev/null || true
            chmod +x "${PREFIX}/bin/remove" 2>/dev/null || true
        fi
    fi

    if [ -f "$HOME/CODEX/files/chat.sh" ]; then
        if [ -d "${PREFIX}/bin" ]; then
            mv -f "$HOME/CODEX/files/chat.sh" "${PREFIX}/bin/chat" 2>/dev/null || cp -f "$HOME/CODEX/files/chat.sh" "${PREFIX}/bin/chat" 2>/dev/null || true
            chmod +x "${PREFIX}/bin/chat" 2>/dev/null || true
        fi
    fi

    if [ -f "$HOME/CODEX/files/dx-simu.sh" ]; then
        mkdir -p "${PREFIX}/.CODEX" 2>/dev/null || true
        mv -f "$HOME/CODEX/files/dx-simu.sh" "${PREFIX}/.CODEX/" 2>/dev/null || cp -f "$HOME/CODEX/files/dx-simu.sh" "${PREFIX}/.CODEX/" 2>/dev/null || true
        chmod +x "${PREFIX}/.CODEX/dx-simu.sh" 2>/dev/null || true
    fi

    # reload termux settings if available
    command -v termux-reload-settings >/dev/null 2>&1 && termux-reload-settings 2>/dev/null || true
}

# -------------------------
# Network check
# -------------------------
dxnetcheck() {
    clear
    ce "${col_b}" "               ╔═══════════════╗"
    ce "${col_d}" "               ║ </>  ${col_c}CODEX-DARK${col_d}  ║"
    ce "${col_b}" "               ╚═══════════════╝"
    ce "${col_c}" "  ╔════════════════════════════════════════════╗"
    ce "${col_c}" "  ║  ${C} ${y}Checking Your Internet Connection${col_c}  ║"
    ce "${col_c}" "  ╚════════════════════════════════════════════╝${n}"
    # Try to reach GitHub; loop until success
    while ! curl --silent --head --fail https://github.com >/dev/null 2>&1; do
        ce "${r}" " No Internet. Retrying in 3 seconds..."
        sleep 3
    done
    clear
}

# -------------------------
# Banner and user customization
# -------------------------
banner_common() {
    echo
    echo
    ce "${y}" "   ░█████╗░░█████╗░██████╗░███████╗██╗░░██╗"
    ce "${col_c}" "   ██╔══██╗██╔══██╗██╔══██╗██╔════╝╚██╗██╔╝"
    ce "${col_b}" "   ██║░░╚═╝██║░░██║██║░░██║█████╗░░░╚███╔╝░"
    ce "${col_d}" "   ██║░░██╗██║░░██║██║░░██║██╔══╝░░░██╔██╗░"
    ce "${col_a}" "   ╚█████╔╝╚█████╔╝██████╔╝███████╗██╔╝╚██╗"
    ce "${p}" "   ░╚════╝░░╚════╝░╚═════╝░╚══════╝╚═╝░░╚═╝"
    echo -e "${y}               +-+-+-+-+-+-+-+-+"
    echo -e "${c}               DARK - GANG"
    echo -e "${y}               +-+-+-+-+-+-+-+-+${n}"
    echo
    if [ $random_number -eq 0 ]; then
        ce "${b}" "╭════════════════════════⊷"
        ce "${b}" "┃ ${g}[${n}ム${g}] ᴛɢ: ${y}t.me/"
        ce "${b}" "╰════════════════════════⊷"
    else
        ce "${b}" "╭══════════════════════════⊷"
        ce "${b}" "┃ ${g}[${n}ム${g}] ᴛɢ: ${y}t.me/Dark_0_gang"
        ce "${b}" "╰══════════════════════════⊷"
    fi
    echo
    ce "${b}" "╭══ ${g}〄 ${y}ᴄᴏᴅᴇx ${g}〄"
    ce "${col_b}" "┃❁ ${g}ᴄʀᴇᴀᴛᴏʀ: ${col_c}ＤＡＲＫ－ＰＲＩＮＣＥ"
    ce "${col_b}" "┃❁ ${g}ᴅᴇᴠɪᴄᴇ: ${y}${VENDOR} ${MODEL}"
    ce "${col_b}" "╰┈➤ ${g}Hey ${y}DARK"
    echo
}

donotchange() {
    clear
    banner_common
    ce "${A}" "${c}Please Enter Your ${g}Banner Name${c}"
    echo

    local name
    # prompt until 1-8 chars
    while true; do
        read -r -p "$(echo -e "${col_c}[+]──[DARK Your Name]────► ${n}")" name
        echo
        if [[ -n "$name" && ${#name} -ge 1 && ${#name} -le 8 ]]; then
            break
        fi
        ce "${E}" "${r}Name must be between ${g}1 and 8${r} characters. ${y}Please try again.${c}"
        echo
    done

    local D1="$HOME/.termux"
    local USERNAME_FILE="$D1/usernames.txt"
    local VERSION="$D1/dx.txt"
    local INPUT_FILE="$HOME/CODEX/files/.zshrc"
    local THEME_INPUT="$HOME/CODEX/files/.codex.zsh-theme"
    local OUTPUT_ZSHRC="$HOME/.zshrc"
    local OUTPUT_THEME="$HOME/.oh-my-zsh/themes/codex.zsh-theme"
    local TEMP_FILE
    TEMP_FILE=$(mktemp "${TMPDIR:-/tmp}/codex.XXXXXX") || TEMP_FILE="$HOME/temp.zshrc"

    mkdir -p "$D1" "$HOME/.oh-my-zsh/themes" 2>/dev/null || true

    # Safely replace SIMU in files if they exist
    if [ -f "$INPUT_FILE" ]; then
        sed "s/SIMU/$name/g" "$INPUT_FILE" > "$TEMP_FILE" || true
    fi
    if [ -f "$THEME_INPUT" ]; then
        sed "s/SIMU/$name/g" "$THEME_INPUT" > "$OUTPUT_THEME" || true
    fi

    echo "$name" > "$USERNAME_FILE" 2>/dev/null || true
    : > "$VERSION" 2>/dev/null || true
    : > "$D1/ads.txt" 2>/dev/null || true

    if [ -f "$TEMP_FILE" ]; then
        mv -f "$TEMP_FILE" "$OUTPUT_ZSHRC" 2>/dev/null || cp -f "$TEMP_FILE" "$OUTPUT_ZSHRC" 2>/dev/null || true
        clear
        ce "${col_d}" "		        Hey ${y}$name"
        echo
        ce "${col_b}" " ${A} ${c}Your Banner created ${g}Successfully¡${c}"
        sleep 2
    else
        ce "${E}" "${r}Failed to prepare zshrc template."
        sleep 1
    fi
    clear
}

# -------------------------
# Setup flow for Termux
# -------------------------
termux_flow() {
    tr_setup
    dxnetcheck
    banner_common
    ce "${col_d}" " ${y}Detected Termux on Android¡"
    ce "${col_b}" " ${A} ${g}Updating packages..¡"
    ce "${col_e}" " ${dm}"
    install_packages
    setup_assets

    if [ -d "$HOME/CODEX" ]; then
        banner_common
        ce "${A}" "${p}Updating Completed...!¡"
        sleep 1
        setup_assets
        donotchange
        banner_common
        ce "${C}" "${c}Type ${g}exit ${c} then ${g}enter ${c}Now Open Your Termux¡¡ ${g}[${n}${HOMES}${g}]${n}"
        sleep 2
        cd "$HOME" || true
        rm -rf "$HOME/CODEX" 2>/dev/null || true
        exit 0
    else
        ce "${E}" "${r}CODEX repository files not found in $HOME/CODEX"
        sleep 2
        exit 1
    fi
}

# -------------------------
# Menu and main loop
# -------------------------
banner2() {
    banner_common
    echo -e "${c}╭════════════════════════════════════════════════⊷"
    echo -e "${c}┃ ${p}❏ ${g}Choose what you want to use. then press Enter${n}"
    echo -e "${c}╰════════════════════════════════════════════════⊷"
}

options=("DARK" "LOUDA")
selected=0

display_menu() {
    clear
    banner2
    echo
    ce "${g}" "■ \e[4m${p}Select An Option\e[0m ${g}▪︎"
    echo
    local i
    for i in "${!options[@]}"; do
        if [ "$i" -eq "$selected" ]; then
            echo -e " ${g}〄> ${c}${options[$i]} ${g}<〄${n}"
        else
            echo -e "     ${options[$i]}"
        fi
    done
    echo
    ce "${col_c}" " Disk: $(check_disk_usage)"
}

# Read arrow keys properly; compatible approach
while true; do
    display_menu
    # read a single key
    IFS= read -rsn1 key 2>/dev/null || true
    if [ -z "$key" ]; then
        # Enter pressed
        case "${options[$selected]}" in
            "DARK")
                ce "${g}" "Continuing..."; sleep 0.4
                if [ "$IS_TERMUX" = true ]; then
                    termux_flow
                else
                    ce "${E}" "${r}This option is intended for Termux on Android. Exiting."
                    exit 2
                fi
                ;;
            "LOUDA")
                ce "${g}" "Opening Telegram..."
                # try xdg-open if available
                if command -v xdg-open >/dev/null 2>&1; then
                    xdg-open "https://t.me/Pranabmallik" >/dev/null 2>&1 || true
                fi
                cd "$HOME" || true
                rm -rf "$HOME/CODEX" 2>/dev/null || true
                exit 0
                ;;
        esac
    else
        # handle escape sequences for arrows
        if [[ "$key" == $'\x1b' ]]; then
            IFS= read -rsn2 -t 0.1 rest 2>/dev/null || rest=''
            key+="$rest"
        fi

        case "$key" in
            $'\x1b[A' | $'\x1bOA') # up
                ((selected--))
                if [ "$selected" -lt 0 ]; then
                    selected=$((${#options[@]} - 1))
                fi
                ;;
            $'\x1b[B' | $'\x1bOB') # down
                ((selected++))
                if [ "$selected" -ge ${#options[@]} ]; then
                    selected=0
                fi
                ;;
            q|Q)
                exit_script
                ;;
            *)
                # ignore other keys
                ;;
        esac
    fi
done
