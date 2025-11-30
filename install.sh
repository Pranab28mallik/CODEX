#!/usr/bin/env bash
clear
# Enhanced color palette for a more colorful install experience

# Basic colors
r='\033[1;91m'   # red
p='\033[1;95m'   # purple/pink
y='\033[1;93m'   # yellow
g='\033[1;92m'   # green
n='\033[1;0m'    # reset / normal
b='\033[1;94m'   # blue
c='\033[1;96m'   # cyan

# Extra bright / alternate colors
m='\033[1;35m'   # magenta
o='\033[1;33m'   # orange (bright yellow)
lg='\033[1;37m'  # light gray / white
dg='\033[1;90m'  # dark gray

# 256-color examples (for terminals that support it)
col_a='\033[38;5;202m' # orange-ish
col_b='\033[38;5;82m'  # lime green
col_c='\033[38;5;99m'  # pinkish
col_d='\033[38;5;45m'  # teal
col_e='\033[38;5;226m' # bright yellow

# dx Symbol (kept)
X='\033[1;92m[\033[1;00m⎯꯭̽𓆩\033[1;92m]\033[1;96m'
D='\033[1;92m[\033[1;00m〄\033[1;92m]\033[1;93m'
E='\033[1;92m[\033[1;00m×\033[1;92m]\033[1;91m'
A='\033[1;92m[\033[1;00m+\033[1;92m]\033[1;92m'
C='\033[1;92m[\033[1;00m</>\033[1;92m]\033[92m'

lm='\033[96m▱▱▱▱▱▱▱▱▱▱▱▱\033[0m〄\033[96m▱▱▱▱▱▱▱▱▱▱▱▱\033[1;00m'
dm='\033[93m▱▱▱▱▱▱▱▱▱▱▱▱\033[0m〄\033[93m▱▱▱▱▱▱▱▱▱▱▱▱\033[1;00m'

# icons
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

MODEL=$(getprop ro.product.model 2>/dev/null)
VENDOR=$(getprop ro.product.manufacturer 2>/dev/null)
devicename="${VENDOR} ${MODEL}"
THRESHOLD=100
random_number=$(( RANDOM % 2 ))

# utility: color-echo helper
ce() {
    # ce <color> <text>
    local color="$1"; shift
    echo -e "${color}${*}${n}"
}

exit_script() {
    clear
    echo
    echo
    echo -e ""
    echo -e "${c}              (\_/)"
    echo -e "              (${y}^_^${c})     ${A} ${g}Hey dear${c}"
    echo -e "             ⊂(___)づ  ⋅˚₊‧ ଳ ‧₊˚ ⋅"
    echo -e "\n ${g}[${n}${KER}${g}] ${c}Exiting ${g}Codex Banner \033[1;36m"
    echo
    cd "$HOME"
    rm -rf CODEX
    exit 0
}

trap exit_script SIGINT SIGTSTP

check_disk_usage() {
    local threshold=${1:-$THRESHOLD}  # Use passed argument or default to THRESHOLD
    local total_size
    local used_size
    local disk_usage

    # Get total size, used size, and disk usage percentage for the home directory
    total_size=$(df -h "$HOME" | awk 'NR==2 {print $2}')
    used_size=$(df -h "$HOME" | awk 'NR==2 {print $3}')
    disk_usage=$(df "$HOME" | awk 'NR==2 {print $5}' | sed 's/%//g')

    # Check if the disk usage exceeds the threshold
    if [ "$disk_usage" -ge "$threshold" ]; then
        echo -e "${g}[${n}\uf0a0${g}] ${r}WARN: ${col_a}Disk Full ${g}${disk_usage}% ${c}| ${c}U${g}${used_size} ${c}of ${c}T${g}${total_size}"
    else
        echo -e "${o}Disk usage: ${col_b}${disk_usage}% ${n}| ${col_c}${used_size}"
    fi
}
data=$(check_disk_usage)

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

start() {
    clear
    LIME='\e[38;5;154m'
    CYAN='\e[36m'
    BLINK='\e[5m'
    NC='\e[0m'
    n=$NC

    type_effect() {
        local text="$1"
        local delay=$2
        local term_width=$(tput cols 2>/dev/null || echo 80)
        local text_length=${#text}
        local padding=$(( (term_width - text_length) / 2 ))
        printf "%${padding}s" ""
        # colorful cycle array
        local colors=("${col_b}" "${col_d}" "${col_c}" "${col_a}" "${col_e}" "${p}" "${m}" "${b}")
        for ((i=0; i<${#text}; i++)); do
            local ch="${text:$i:1}"
            local col="${colors[$((i % ${#colors[@]}))]}"
            printf "${col}${BLINK}%s${NC}" "$ch"
            # occasional spark using a different color
            if (( RANDOM % 4 == 0 )); then
                printf "${y}.\b"
                sleep 0.02
                printf "\b"
            fi
            sleep "$delay"
        done
        echo
    }

    echo
    echo
    echo
    type_effect "[ DARK-CODEX STARTED]" 0.04
    sleep 0.2
    type_effect "「HELLO DEAR USER'S DARK GANG 」" 0.08
    sleep 0.5
    type_effect "【DARK-CODEX WILL PROTECT YOU】" 0.08
    sleep 0.7
    type_effect "<DARK_GANG>" 0.08
    sleep 0.2
    type_effect "[ENJOY DARK MEMBERS]" 0.08
    sleep 0.5
    type_effect "!D A R K - G A N G¡" 0.08
    echo
    sleep 2
    clear
}
start

mkdir -p .Codex-Dark

tr() {
    # Check if curl is installed
    if command -v curl &>/dev/null; then
        :
    else
        pkg install curl -y &>/dev/null 2>&1
    fi
    # ncurses-utils install check (some systems have different package names)
    if command -v ncurses-utils &>/dev/null || command -v ncurses5-config &>/dev/null; then
        :
    else
        pkg install ncurses-utils -y >/dev/null 2>&1
    fi
}

help() {
    clear
    echo
    ce "${p}" "■ \e[4m${g}Use Button\e[4m ${p}▪︎"
    echo
    ce "${y}" "Use Termux Extra key Button"
    echo
    ce "${col_b}" " UP          ↑"
    ce "${col_b}" " DOWN        ↓"
    echo
    ce "${g}" "Prass Dark-Gang Click Enter"
    echo
    ce "${b}" "■ \e[4m${c}If you understand, click the Enter Button\e[4m ${b}▪︎"
    read -p "" -r
}
help

spin() {
    echo
    local delay=0.40
    local spinner=('█■■■■' '■█■■■' '■■█■■' '■■■█■' '■■■■█')

    show_spinner() {
        local pid=$!
        while ps -p $pid > /dev/null 2>&1; do
            for i in "${spinner[@]}"; do
                tput civis 2>/dev/null || true
                # rotate colors for spinner
                local cols=("${col_a}" "${col_b}" "${col_c}" "${col_d}" "${col_e}" "${p}" "${m}")
                local idx=$((RANDOM % ${#cols[@]}))
                echo -ne "${cols[$idx]}\r [+] Installing $1 Dark wait \e[33m[\033[1;92m$i\033[1;93m]\033[1;0m   "
                sleep $delay
                printf "\b\b\b\b\b\b\b\b"
            done
        done
        printf "   \b\b\b\b\b"
        tput cnorm 2>/dev/null || true
        printf "\e[1;93m [Done $1]\e[0m\n"
        echo
        sleep 1
    }

    apt update >/dev/null 2>&1
    apt upgrade -y >/dev/null 2>&1

    packages=("git" "python" "ncurses-utils" "jq" "figlet" "termux-api" "lsd" "zsh" "ruby" "exa")

    for package in "${packages[@]}"; do
        if ! dpkg -l 2>/dev/null | grep -q "^ii  $package "; then
            pkg install "$package" -y >/dev/null 2>&1 &
            show_spinner "$package"
        fi
    done

    if ! command -v lolcat >/dev/null 2>&1 || ! pip show lolcat >/dev/null 2>&1; then
        pip install lolcat >/dev/null 2>&1 &
        show_spinner "lolcat(pip)"
    fi

    rm -rf data/data/com.termux/files/usr/bin/chat >/dev/null 2>&1
    if [ ! -f "$HOME/.Codex-simu/report" ]; then
        mv "$HOME/CODEX/files/report" "$HOME/.Codex-simu" &
        show_spinner "Codex-report"
    fi
    if [ ! -f "/data/data/com.termux/files/usr/bin/chat" ]; then
        mv "$HOME/CODEX/files/chat.sh" /data/data/com.termux/files/usr/bin/chat &
        chmod +x /data/data/com.termux/files/usr/bin/chat &
        show_spinner "chat"
    fi

    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh >/dev/null 2>&1 &
        show_spinner "oh-my-zsh"
    fi

    rm -rf /data/data/com.termux/files/usr/etc/motd >/dev/null 2>&1

    if [ "$SHELL" != "/data/data/com.termux/files/usr/bin/zsh" ]; then
        chsh -s zsh >/dev/null 2>&1 &
        show_spinner "zsh-shell"
    fi

    if [ ! -f "$HOME/.zshrc" ]; then
        rm -rf ~/.zshrc >/dev/null 2>&1
        cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc &
        show_spinner "zshrc"
    fi

    if [ ! -d "/data/data/com.termux/files/home/.oh-my-zsh/plugins/zsh-autosuggestions" ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions /data/data/com.termux/files/home/.oh-my-zsh/plugins/zsh-autosuggestions >/dev/null 2>&1 &
        show_spinner "zsh-autosuggestions"
    fi

    if [ ! -d "/data/data/com.termux/files/home/.oh-my-zsh/plugins/zsh-syntax-highlighting" ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /data/data/com.termux/files/home/.oh-my-zsh/plugins/zsh-syntax-highlighting >/dev/null 2>&1 &
        show_spinner "zsh-syntax"
    fi

    if ! gem list lolcat >/dev/null 2>&1; then
        echo "y" | gem install lolcat > /dev/null 2>&1 &
        show_spinner "lolcat「Advance」"
    fi
}

# dx setup
setup() {
    # dx move
    ds="$HOME/.termux"
    dx="$ds/font.ttf"
    simu="$ds/colors.properties"
    if [ -f "$dx" ]; then
        :
    else
        cp "$HOME/CODEX/files/font.ttf" "$ds"
    fi

    if [ -f "$simu" ]; then
        :
    else
        cp "$HOME/CODEX/files/colors.properties" "$ds"
    fi
    cp "$HOME/CODEX/files/ASCII-Shadow.flf" "$PREFIX/share/figlet/" 2>/dev/null || true
    mv "$HOME/CODEX/files/remove" /data/data/com.termux/files/usr/bin/ 2>/dev/null || true
    chmod +x /data/data/com.termux/files/usr/bin/remove 2>/dev/null || true
    mv "$HOME/CODEX/files/dx-simu.sh" /data/data/com.termux/.CODEX/ 2>/dev/null || true
    chmod +x /data/data/com.termux/.CODEX/ 2>/dev/null || true
    termux-reload-settings 2>/dev/null || true
}

dxnetcheck() {
    clear
    echo
    ce "${col_b}" "               ╔═══════════════╗"
    ce "${col_d}" "               ║ </>  ${col_c}CODEX-DARK${col_d}  ║"
    ce "${col_b}" "               ╚═══════════════╝"
    ce "${col_c}" "  ╔════════════════════════════════════════════╗"
    ce "${col_c}" "  ║  ${C} ${y}Checking Your Internet Connection¡${col_c}  ║"
    ce "${col_c}" "  ╚════════════════════════════════════════════╝${n}"
    while true; do
        curl --silent --head --fail https://github.com > /dev/null 2>&1
        if [ "$?" != 0 ]; then
            ce "${r}" "              ╔══════════════════╗"
            ce "${r}" "              ║${C} ${r}No Internet ${g}║"
            ce "${r}" "              ╚══════════════════╝"
            sleep 2.5
        else
            break
        fi
    done
    clear
}

donotchange() {
    clear
    echo
    echo
    echo -e ""
    echo -e "${c}              (\_/)"
    echo -e "              (${y}^_^${c})     ${A} ${g}Hey dear${c}"
    echo -e "             ⊂(___)づ  ⋅˚₊‧ ଳ ‧₊˚ ⋅"
    echo
    ce "${A}" "${c}Please Enter Your ${g}Banner Name${c}"
    echo

    # Loop to prompt until valid name (1-8 characters)
    while true; do
        read -p "$(echo -e "${col_c}[+]──[DARK Your Name]────► ${n}")" name
        echo
        if [[ ${#name} -ge 1 && ${#name} -le 8 ]]; then
            break
        else
            ce "${E}" "${r}Name must be between ${g}1 and 8${r} characters. ${y}Please try again.${c}"
            echo
        fi
    done

    # Specify directories and files
    D1="$HOME/.termux"
    USERNAME_FILE="$D1/usernames.txt"
    VERSION="$D1/dx.txt"
    INPUT_FILE="$HOME/CODEX/files/.zshrc"
    THEME_INPUT="$HOME/CODEX/files/.codex.zsh-theme"
    OUTPUT_ZSHRC="$HOME/.zshrc"
    OUTPUT_THEME="$HOME/.oh-my-zsh/themes/codex.zsh-theme"
    TEMP_FILE="$HOME/temp.zshrc"  # Actual temporary file

    # Use sed to replace SIMU with the name and save to temporary file
    sed "s/SIMU/$name/g" "$INPUT_FILE" > "$TEMP_FILE" &&
    sed "s/SIMU/$name/g" "$THEME_INPUT" > "$OUTPUT_THEME" &&
    echo "$name" > "$USERNAME_FILE" &&
    echo "" > "$VERSION"
    echo "" > "$D1/ads.txt"

    if [[ $? -eq 0 ]]; then
        mv "$TEMP_FILE" "$OUTPUT_ZSHRC"
        clear
        echo
        echo
        ce "${col_d}" "		        Hey ${y}$name"
        echo -e "${c}              (\_/)"
        echo -e "              (${y}^ω^${c})     ${g}I'm Dx-Simu${c}"
        echo -e "             ⊂(___)づ  ⋅˚₊‧ ଳ ‧₊˚ ⋅"
        echo
        ce "${col_b}" " ${A} ${c}Your Banner created ${g}Successfully¡${c}"
        echo
        sleep 3
    else
        echo
        ce "${E}" "${r}Error occurred while processing the file."
        sleep 1
        rm -f "$TEMP_FILE"
    fi

    echo
    clear
}

banner() {
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
    ce "${col_b}" "┃❁ ${g}ᴄʀᴇᴀᴛᴏʀ: ${col_c}ＤＡＲＫ－ＰＲＩＮＣＥ  ايڪـͬــͤــᷜــͨــͣــͪـي"
    ce "${col_b}" "┃❁ ${g}ᴅᴇᴠɪᴄᴇ: ${y}${VENDOR} ${MODEL}"
    ce "${col_b}" "╰┈➤ ${g}Hey ${y}DARK"
    echo
}

termux() {
    spin
}

setupx() {
    if [ -d "/data/data/com.termux/files/usr/" ]; then
        tr
        dxnetcheck

        banner
        ce "${col_d}" " ${y}Detected Termux on Android¡"
        ce "${col_a}" " ${lm}"
        ce "${col_b}" " ${A} ${g}Updating Package..¡"
        ce "${col_e}" " ${dm}"
        ce "${col_c}" " ${A} ${g}Wait a few minutes.${n}"
        ce "${col_b}" " ${lm}"
        termux
        # dx check if D1DOS folder exists
        if [ -d "$HOME/CODEX" ]; then
            sleep 2
            clear
            banner
            ce "${A}" "${p}Updating Completed...!¡"
            ce "${dm}" "${dm}"
            clear
            banner
            ce "${C}" "${c}Package Setup Your Termux..${n}"
            echo
            ce "${A}" "${g}Wait a few minutes.${n}"
            setup
            donotchange
            clear
            banner
            ce "${C}" "${c}Type ${g}exit ${c} then ${g}enter ${c}Now Open Your Termux¡¡ ${g}[${n}${HOMES}${g}]${n}"
            echo
            sleep 3
            cd "$HOME"
            rm -rf CODEX
            exit 0
        else
            clear
            banner
            ce "${E}" "${r}Tools Not Exits Your Terminal.."
            echo
            echo
            sleep 3
            exit
        fi
    else
        ce "${E}" "${r}Sorry, this operating system is not supported ${p}| ${g}[${n}${HOST}${g}] ${SHELL}${n}"
        echo
        ce "${A}" "${g} Wait for the next update using Linux...!¡"
        echo
        sleep 3
        exit
    fi
}

banner2() {
    echo
    echo
    ce "${y}" "   ░█████╗░░█████╗░██████╗░███████╗██╗░░██╗"
    ce "${col_c}" "   ██╔══██╗██╔══██╗██╔══██╗██╔════╝╚██╗██╔╝"
    ce "${col_b}" "   ██║░░╚═╝██║░░██║██║░░██║█████╗░░░╚███╔╝░"
    ce "${col_d}" "   ██║░░██╗██║░░██║██║░░██║██╔══╝░░░██╔██╗░"
    ce "${col_a}" "   ╚█████╔╝╚█████╔╝██████╔╝███████╗██╔╝╚██╗"
    ce "${p}" "   ░╚════╝░░╚════╝░╚═════╝░╚══════╝╚═╝░░╚═╝"
    echo -e "${y}               +-+-+-+-+-+-+-+-+"
    echo -e "${c}               |DARK - GANG|"
    echo -e "${y}               +-+-+-+-+-+-+-+-+${n}"
    echo
    if [ $random_number -eq 0 ]; then
        ce "${b}" "╭════════════════════════⊷"
        ce "${b}" "┃ ${g}[${n}ム${g}] ᴛɢ: ${y}t.me/Pranabmallik"
        ce "${b}" "╰════════════════════════⊷"
    else
        ce "${b}" "╭══════════════════════════⊷"
        ce "${b}" "┃ ${g}[${n}ム${g}] ᴛɢ: ${y}t.me/Pranabmallik"
        ce "${b}" "╰══════════════════════════⊷"
    fi
    echo
    ce "${b}" "╭══ ${g}〄 ${y}DARK ${g}〄"
    ce "${b}" "┃❁ ${g}ᴄʀᴇᴀᴛᴏʀ: ${y}ＤＡＲＫ－ＰＲＩＮＣＥ  ايڪـͬــͤــᷜــͨــͣــͪـي"
    ce "${b}" "╰┈➤ ${g}Hey ${y}DARK"
    echo
    ce "${c}" "╭════════════════════════════════════════════════⊷"
    ce "${c}" "┃ ${p}❏ ${g}Choose what you want to use. then Click Enter${n}"
    ce "${c}" "╰════════════════════════════════════════════════⊷"
}

options=("DARK" "LOUDA")
selected=0
display_menu() {
    clear
    banner2
    echo
    ce "${g}" "■ \e[4m${p}Select An Option\e[0m ${g}▪︎"
    echo
    for i in "${!options[@]}"; do
        if [ $i -eq $selected ]; then
            echo -e " ${g}〄> ${col_b}${options[$i]} ${g}<〄${n}"
        else
            echo -e "     ${options[$i]}"
        fi
    done
}

# Main loop
while true; do
    display_menu
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
            '[B')
                ((selected++))
                if [ $selected -ge ${#options[@]} ]; then
                    selected=0
                fi
                ;;
            *)
                display_menu
                ;;
        esac
    elif [[ "$input" == "" ]]; then # Enter key
        case ${options[$selected]} in
            "DARK")
                echo -e "\n ${g}[${n}${HOMES}${g}] ${c}Continue Free..!${n}"
                sleep 1
                setupx
                ;;
            "LOUDA")
                echo -e "\n ${g}[${n}${HOST}${g}] ${c}Wait for opening Telegram..!${n}"
                sleep 1
                xdg-open "https://t.me/Pranabmallik" 2>/dev/null || true
                cd "$HOME"
                rm -rf CODEX
                exit 0
                ;;
        esac
    fi
done    IFS=''
    sentence=$1
    second=${2:-0.05}
    for (( i=0; i<${#sentence}; i++ )); do
        char=${sentence:$i:1}
        echo -n "$char"
        sleep $second
    done
    echo
}

start() {
clear
LIME='\e[38;5;154m'
CYAN='\e[36m'
BLINK='\e[5m'
NC='\e[0m'
n=$NC

 type_effect() {
    local text="$1"
    local delay=$2
    local term_width=$(tput cols)
    local text_length=${#text}
    local padding=$(( (term_width - text_length) / 2 ))
    printf "%${padding}s" ""
    for ((i=0; i<${#text}; i++)); do
        printf "${LIME}${BLINK}${text:$i:1}${NC}"
        if (( RANDOM % 3 == 0 )); then
            printf "${CYAN} ${NC}"
            sleep 0.05
            printf "\b"
        fi
        sleep "$delay"
    done
    echo
}
echo
echo
echo
type_effect "[ DARK-CODEX STARTED]" 0.04
sleep 0.2
type_effect "「HELLO DEAR USER'S DARK GANG 」" 0.08
sleep 0.5
type_effect "【DARK-CODEX WILL PROTECT YOU】" 0.08
sleep 0.7
type_effect "<DARK_GANG>" 0.08
sleep 0.2
type_effect "[ENJOY DARK MEMBERS]" 0.08
sleep 0.5
type_effect "!D A R K - G A N G¡" 0.08
echo
sleep 2
clear 
}
start
mkdir -p .Codex-Dark
tr() {
# Check if curl is installed
if command -v curl &>/dev/null; then
    echo ""
else
    pkg install curl -y &>/dev/null 2>&1
fi
if command -v ncurses-utils -y &>/dev/null; then
    echo ""
else
    pkg install ncurses-utils -y >/dev/null 2>&1
fi
}
help() {
clear
echo
echo -e " ${p}■ \e[4m${g}Use Button\e[4m ${p}▪︎${n}"
    echo
echo -e " ${y}Use Termux Extra key Button${n}"
echo
echo -e " UP          ↑"
echo -e " DOWN        ↓"
echo
echo -e " ${g}Prass Dark-Gang Click Enter"
echo
echo -e " ${b}■ \e[4m${c}If you understand, click the Enter Button\e[4m ${b}▪︎${n}"
read -p ""
}
help
spin() {
echo
    local delay=0.40
    local spinner=('█■■■■' '■█■■■' '■■█■■' '■■■█■' '■■■■█')

    show_spinner() {
        local pid=$!
        while ps -p $pid > /dev/null; do
            for i in "${spinner[@]}"; do
                tput civis
                echo -ne "\033[1;96m\r [+] Installing $1 Dark wait \e[33m[\033[1;92m$i\033[1;93m]\033[1;0m   "
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

    apt update >/dev/null 2>&1
    apt upgrade -y >/dev/null 2>&1
    
    packages=("git" "python" "ncurses-utils" "jq" "figlet" "termux-api" "lsd" "zsh" "ruby" "exa")

    for package in "${packages[@]}"; do
        if ! dpkg -l | grep -q "^ii  $package "; then
            pkg install "$package" -y >/dev/null 2>&1 &
            show_spinner "$package"
        fi
    done

    if ! command -v lolcat >/dev/null 2>&1 || ! pip show lolcat >/dev/null 2>&1; then
        pip install lolcat >/dev/null 2>&1 &
        show_spinner "lolcat(pip)"
    fi
    
    rm -rf data/data/com.termux/files/usr/bin/chat >/dev/null 2>&1
    if [ ! -f "$HOME/.Codex-simu/report" ]; then
        mv $HOME/CODEX/files/report $HOME/.Codex-simu &
        show_spinner "Codex-report"
    fi
    if [ ! -f "/data/data/com.termux/files/usr/bin/chat" ]; then
        mv $HOME/CODEX/files/chat.sh /data/data/com.termux/files/usr/bin/chat &
        chmod +x /data/data/com.termux/files/usr/bin/chat &
        show_spinner "chat"
    fi
    
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh >/dev/null 2>&1 &
        show_spinner "oh-my-zsh"
    fi
    
    rm -rf /data/data/com.termux/files/usr/etc/motd >/dev/null 2>&1
    
    if [ "$SHELL" != "/data/data/com.termux/files/usr/bin/zsh" ]; then
        chsh -s zsh >/dev/null 2>&1 &
        show_spinner "zsh-shell"
    fi
    
    if [ ! -f "$HOME/.zshrc" ]; then
        rm -rf ~/.zshrc >/dev/null 2>&1
        cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc &
        show_spinner "zshrc"
    fi
    
    if [ ! -d "/data/data/com.termux/files/home/.oh-my-zsh/plugins/zsh-autosuggestions" ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions /data/data/com.termux/files/home/.oh-my-zsh/plugins/zsh-autosuggestions >/dev/null 2>&1 &
        show_spinner "zsh-autosuggestions"
    fi
    
    if [ ! -d "/data/data/com.termux/files/home/.oh-my-zsh/plugins/zsh-syntax-highlighting" ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /data/data/com.termux/files/home/.oh-my-zsh/plugins/zsh-syntax-highlighting >/dev/null 2>&1 &
        show_spinner "zsh-syntax"
    fi
    
    if ! gem list lolcat >/dev/null 2>&1; then
        echo "y" | gem install lolcat > /dev/null 2>&1 &
        show_spinner "lolcat「Advance」"
    fi
}
# dx setup
setup() {
# dx move
ds="$HOME/.termux"
dx="$ds/font.ttf"
simu="$ds/colors.properties"
if [ -f "$dx" ]; then
    echo
else
	cp $HOME/CODEX/files/font.ttf "$ds"
fi

if [ -f "$simu" ]; then
    echo
else 
        
	cp $HOME/CODEX/files/colors.properties "$ds"
fi
cp $HOME/CODEX/files/ASCII-Shadow.flf $PREFIX/share/figlet/
mv $HOME/CODEX/files/remove /data/data/com.termux/files/usr/bin/
chmod +x /data/data/com.termux/files/usr/bin/remove
mv $HOME/CODEX/files/dx-simu.sh /data/data/com.termux/.CODEX/
chmod +x  /data/data/com.termux/.CODEX/
termux-reload-settings
}
dxnetcheck() {
clear
clear
echo
echo -e "               ${g}╔═══════════════╗"
echo -e "               ${g}║ ${n}</>  ${c}CODEX-DARK${g}  ║"
echo -e "               ${g}╚═══════════════╝"
echo -e "  ${g}╔════════════════════════════════════════════╗"
echo -e "  ${g}║  ${C} ${y}Checking Your Internet Connection¡${g}  ║"
echo -e "  ${g}╚════════════════════════════════════════════╝${n}"
while true; do
    curl --silent --head --fail https://github.com > /dev/null
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

donotchange() {
    clear
    echo
    echo
    echo -e ""
    echo -e "${c}              (\_/)"
    echo -e "              (${y}^_^${c})     ${A} ${g}Hey dear${c}"
    echo -e "             ⊂(___)づ  ⋅˚₊‧ ଳ ‧₊˚ ⋅"
    echo
    echo -e " ${A} ${c}Please Enter Your ${g}Banner Name${c}"
    echo

    # Loop to prompt until valid name (1-8 characters)
    while true; do
        read -p "[+]──[DARK Your Name]────► " name
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
    INPUT_FILE="$HOME/CODEX/files/.zshrc"
    THEME_INPUT="$HOME/CODEX/files/.codex.zsh-theme"
    OUTPUT_ZSHRC="$HOME/.zshrc"
    OUTPUT_THEME="$HOME/.oh-my-zsh/themes/codex.zsh-theme"
    TEMP_FILE="$HOME/temp.zshrc"  # Actual temporary file

    # Use sed to replace SIMU with the name and save to temporary file
    sed "s/SIMU/$name/g" "$INPUT_FILE" > "$TEMP_FILE" &&
    sed "s/SIMU/$name/g" "$THEME_INPUT" > "$OUTPUT_THEME" &&
    echo "$name" > "$USERNAME_FILE" &&
    echo "" > "$VERSION"
	echo "" > "$D1/ads.txt"

    # Check if all operations were successful
    if [[ $? -eq 0 ]]; then
        # Move the temporary file to the original output
        mv "$TEMP_FILE" "$OUTPUT_ZSHRC"
        clear
        echo
        echo
        echo -e "		        ${g}Hey ${y}$name"
        echo -e "${c}              (\_/)"
        echo -e "              (${y}^ω^${c})     ${g}I'm Dx-Simu${c}"
        echo -e "             ⊂(___)づ  ⋅˚₊‧ ଳ ‧₊˚ ⋅"
        echo
        echo -e " ${A} ${c}Your Banner created ${g}Successfully¡${c}"
        echo
        sleep 3
    else
        echo
        echo -e " ${E} ${r}Error occurred while processing the file."
        sleep 1
        # Clean up temporary file if sed fails
        rm -f "$TEMP_FILE"
    fi

    echo
    clear
}

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
echo -e "${c}               DARK - GANG"
echo -e "${y}               +-+-+-+-+-+-+-+-+${n}"
echo
 if [ $random_number -eq 0 ]; then
echo -e "${b}╭════════════════════════⊷"
echo -e "${b}┃ ${g}[${n}ム${g}] ᴛɢ: ${y}t.me/"
echo -e "${b}╰════════════════════════⊷"
        else
echo -e "${b}╭══════════════════════════⊷"
echo -e "${b}┃ ${g}[${n}ム${g}] ᴛɢ: ${y}t.me/Dark_0_gang"
echo -e "${b}╰══════════════════════════⊷"
        fi
echo
echo -e "${b}╭══ ${g}〄 ${y}ᴄᴏᴅᴇx ${g}〄"
echo -e "${b}┃❁ ${g}ᴄʀᴇᴀᴛᴏʀ: ${y}ＤＡＲＫ－ＰＲＩＮＣＥ  ايڪـͬــͤــᷜــͨــͣــͪـي"
echo -e "${b}┃❁ ${g}ᴅᴇᴠɪᴄᴇ: ${y}${VENDOR} ${MODEL}"
echo -e "${b}╰┈➤ ${g}Hey ${y}DARK"
echo
}
termux() {
spin
}

setupx() {
if [ -d "/data/data/com.termux/files/usr/" ]; then
    tr
    dxnetcheck
    
    banner
    echo -e " ${C} ${y}Detected Termux on Android¡"
	echo -e " ${lm}"
	echo -e " ${A} ${g}Updating Package..¡"
	echo -e " ${dm}"
    echo -e " ${A} ${g}Wait a few minutes.${n}"
    echo -e " ${lm}"
    termux
    # dx check if D1DOS folder exists
    if [ -d "$HOME/CODEX" ]; then
        sleep 2
	clear
	banner
	echo -e " ${A} ${p}Updating Completed...!¡"
	echo -e " ${dm}"
	clear
	banner
	echo -e " ${C} ${c}Package Setup Your Termux..${n}"
	echo
	echo -e " ${A} ${g}Wait a few minutes.${n}"
	setup
        donotchange
	clear
        banner
        echo -e " ${C} ${c}Type ${g}exit ${c} then ${g}enter ${c}Now Open Your Termux¡¡ ${g}[${n}${HOMES}${g}]${n}"
	echo
	sleep 3
	cd "$HOME"
	rm -rf CODEX
	exit 0
	    else
        clear
        banner
    echo -e " ${E} ${r}Tools Not Exits Your Terminal.."
	echo
	echo
	sleep 3
	exit
    fi
else
echo -e " ${E} ${r}Sorry, this operating system is not supported ${p}| ${g}[${n}${HOST}${g}] ${SHELL}${n}"
echo 
echo -e " ${A} ${g} Wait for the next update using Linux...!¡"
    echo
	sleep 3
	exit
    fi
}
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
echo -e "${c}               |DARK - GANG|"
echo -e "${y}               +-+-+-+-+-+-+-+-+${n}"
echo
 if [ $random_number -eq 0 ]; then
echo -e "${b}╭════════════════════════⊷"
echo -e "${b}┃ ${g}[${n}ム${g}] ᴛɢ: ${y}t.me/Pranabmallik"
echo -e "${b}╰════════════════════════⊷"
        else
echo -e "${b}╭══════════════════════════⊷"
echo -e "${b}┃ ${g}[${n}ム${g}] ᴛɢ: ${y}t.me/Pranabmallik"
echo -e "${b}╰══════════════════════════⊷"
        fi
echo
echo -e "${b}╭══ ${g}〄 ${y}DARK ${g}〄"
echo -e "${b}┃❁ ${g}ᴄʀᴇᴀᴛᴏʀ: ${y}ＤＡＲＫ－ＰＲＩＮＣＥ  ايڪـͬــͤــᷜــͨــͣــͪـي"
echo -e "${b}╰┈➤ ${g}Hey ${y}DARK"
echo
echo -e "${c}╭════════════════════════════════════════════════⊷"
echo -e "${c}┃ ${p}❏ ${g}Choose what you want to use. then Click Enter${n}"
echo -e "${c}╰════════════════════════════════════════════════⊷"

}
options=("DARK" "LOUDA")
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
            '[B') 
                ((selected++))
                if [ $selected -ge ${#options[@]} ]; then
                    selected=0
                fi
                ;;
            *)
                display_menu
                ;;
        esac
    elif [[ "$input" == "" ]]; then # Enter key
        case ${options[$selected]} in
            "DARK")
            echo -e "\n ${g}[${n}${HOMES}${g}] ${c}Continue Free..!${n}"
                sleep 1
                setupx
                ;;
            "LOUDA")
                echo -e "\n ${g}[${n}${HOST}${g}] ${c}Wait for opening Telegram..!${n}"
                sleep 1
                xdg-open "https://t.me/Pranabmallik"
                cd "$HOME"
            	rm -rf CODEX
                exit 0
                ;;
        esac
    fi
done
