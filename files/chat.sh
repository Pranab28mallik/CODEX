#!/bin/bash
clear
if ! command -v curl &> /dev/null; then
    pkg install curl -y &> /dev/null
else
echo
fi
clear
r='\033[1;91m'
p='\033[1;95m'
y='\033[1;93m'
g='\033[1;92m'
n='\033[1;0m'
b='\033[1;94m'
c='\033[1;96m'

# dx Symbol
X='\033[1;92m[\033[1;00m⎯꯭̽𓆩\033[1;92m]\033[1;96m'
D='\033[1;92m[\033[1;00m〄\033[1;92m]\033[1;93m'
E='\033[1;92m[\033[1;00m×\033[1;92m]\033[1;91m'
A='\033[1;92m[\033[1;00m+\033[1;92m]\033[1;92m'
C='\033[1;92m[\033[1;00m</>\033[1;92m]\033[92m'
lm='\033[1;96m▱▱▱▱▱▱\033[1;0m〄\033[1;96m▱▱▱▱▱▱\033[1;00m'
dm='\033[1;93m▱▱▱▱▱▱\033[1;0m〄\033[1;93m▱▱▱▱▱▱\033[1;00m'


URL="https://codex-chat-hew1.onrender.com"
USERNAME_DIR="$HOME/.DARK"
USERNAME_FILE="$USERNAME_DIR/usernames.txt"
random_number=$(( RANDOM % 2 ))

inter() {
clear
echo
echo -e "               ${g}╔═══════════════╗"
echo -e "               ${g}║ ${n}</>  ${c}DARK-X${g}   ║"
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

load() {
clear
echo -e " ${r}●${n}"
sleep 0.2
clear
echo -e " ${r}●${y}●${n}"
sleep 0.2
clear
echo -e " ${r}●${y}●${b}●${n}"
sleep 0.2
}

# Function to display warnings
check_warnings() {
    warning=$(curl -s "$URL/warnings" | jq -r --arg user "$username" '.[] | select(.username == $user) | "Are You Warned — °|\(.username)|°  \(.warning)"')
    if [ -n "$warning" ]; then
        echo -e "         ${r}$warning${n}"
    else
    cd
    fi
}


broken() {
clear
echo
echo -e "${c}        _(\___/)"
echo -e "      =( ´ ${g}•⁠${p}ω${g}• ⁠${c})=   ˖<💌>."
echo -e "      // ͡     )︵)"
echo -e "     (⁠人_____づ_づ"
echo
sleep 0.5
clear
echo
echo -e "${c}        _(\___/)"
echo -e "      =( ´ ${g}•⁠${p}ω${g}• ⁠${c})=   𖥔˖<💘>.𖥔"
echo -e "      // ͡     )︵)"
echo -e "     (⁠人_____づ_づ"
echo
sleep 0.5
clear
echo
echo -e "${c}        _(\___/)"
echo -e "      =( ´ ${g}•⁠${p}ω${g}• ⁠${c})=   .𖥔 ˖<💘>.𖥔 ݁"
echo -e "      // ͡     )︵)"
echo -e "     (⁠人_____づ_づ"
echo
sleep 0.5
clear
echo
echo -e "${c}        _(\___/)"
echo -e "      =( ´ ${g}•⁠${p}ω${g}• ⁠${c})=   𖥔 ݁ ˖<💛>.𖥔 ݁ "
echo -e "      // ͡     )︵)"
echo -e "     (⁠人_____づ_づ"
echo
sleep 0.5
clear
echo
echo -e "${c}        _(\___/)"
echo -e "      =( ´ ${g}•⁠${p}ω${g}• ⁠${c})=   .𖥔 ݁ ˖<💗>.𖥔 ݁ ˖"
echo -e "      // ͡     )︵)"
echo -e "     (⁠人_____づ_づ"
echo
sleep 0.5
clear
echo
echo -e "${c}        _(\___/)"
echo -e "      =( ´ ${g}•⁠${p}ω${g}• ⁠${c})=   ₊ଳ ‧₊˚ ⋅.𖥔 ݁ ˖<💔>.𖥔 ݁ ˖⋅˚₊‧ ଳ₊"
echo -e "      // ͡     )︵)"
echo -e "     (⁠人_____づ_づ"
echo
sleep 0.5
echo -e " ${C} ${g}Goodbye! ${y}(${c}-${r}.${c}-${y})${c}Zzz・・・・𑁍ࠬܓ"
echo
exit 0
}

goodbye() {
clear
echo
echo -e "${c}     ࿔‧ ֶָ֢˚˖𐦍˖˚ֶָ֢ ‧࿔       ╱|、"
echo -e "                      (${b}˚${p}ˎ ${b}。${c}7"
echo -e "                       |、~〵"
echo -e "                       じしˍ,)⼃"
echo
sleep 0.5
clear
echo
echo -e "${c}      ࿔‧ ֶָ֢˚˖𐦍˖˚ֶָ֢ ‧࿔      ╱|、"
echo -e "                      (${b}˚${p}ˎ ${b}。${c}7"
echo -e "                       |、~〵"
echo -e "                       じしˍ,)ノ"
echo
sleep 0.5
clear
echo
echo -e "${c}     ࿔‧ ֶָ֢˚˖𐦍˖˚ֶָ֢ ‧࿔       ╱|、"
echo -e "                      (${b}˚${p}ˎ ${b}。${c}7"
echo -e "                       |、~〵"
echo -e "                       じしˍ,)⼃"
echo
sleep 0.5
clear
echo
echo -e "${c}     ࿔‧ ֶָ֢˚˖𐦍˖˚ֶָ֢ ‧࿔       ╱|、"
echo -e "                      (${b}˚${p}ˎ ${b}。${c}7"
echo -e "                       |、~〵"
echo -e "                       じしˍ,)ノ"
echo
sleep 0.5
clear
echo
echo -e "${c}      ࿔‧ ֶָ֢˚˖𐦍˖˚ֶָ֢ ‧࿔      ╱|、"
echo -e "                      (${b}˚${p}ˎ ${b}。${c}7"
echo -e "                       |、~〵"
echo -e "                       じしˍ,)⼃"
echo
sleep 0.5
clear
echo
echo -e "${c}      ࿔‧ ֶָ֢˚˖𐦍˖˚ֶָ֢ ‧࿔      ╱|、"
echo -e "                      (${b}˚${p}ˎ ${b}。${c}7"
echo -e "                       |、~〵"
echo -e "                       じしˍ,)ノ"
echo
sleep 0.5
echo -e " ${C} ${g}Goodbye! ${y}(${c}-${r}.${c}-${y})${c}Zzz・・・・ཐི|ཋྀ"
echo
exit 0
}

dx() {
clear
echo
echo -e " ${p}■ \e[4m${g}Use Tools\e[4m ${p}▪︎${n}"
    echo
echo -e " ${y}Enter ${g}q ${y}Exit Tool${n}"
echo
echo -e "             q"
echo
echo -e " ${b}■ \e[4m${c}If you understand, click the Enter Button\e[4m ${b}▪︎${n}"
read -p ""
}

# Function to display messages
display_messages() {
    clear
    banned=$(curl -s "$URL/ban" | jq -r --arg user "$username" '.[] | select(.username == $user) | "Are You banned — °|\(.username)|°  \(.bn_mesg)"')
    if [ -n "$banned" ]; then
     load
echo -e "     ${c}____    __    ____  _  _     _  _ "
echo -e "    ${c}(  _ \  /__\  (  _ \( )/ )___( \/ )"
echo -e "    ${y} )(_) )/(__)\  )   / )  ((___))  ("
echo -e "   ${y} (____/(__)(__)(_)\_)(_)\_)   (_/\_)\n"
        echo -e "         ${r}$banned${n}"
     echo
     exit 0
    else
    cd
    fi
clear
    load
    while true; do
    clear
    echo -e " ${r}●${y}●${b}●${n}"
    check_warnings
        D=$(date +"${c}%Y-%b-%d${n}")
        T=$(date +"${c}%I:%M %p${n}")
        echo -e "${lm}"
        echo -e " $D"
        echo -e "  ${c}┏┓┓┏┏┓┏┳┓"
        echo -e "  ${c}┃ ┣┫┣┫ ┃               ${C} ${g}t.me/Pranabmallik"
        echo -e "  ${c}┗┛┛┗┛┗ ┻"
        echo -e "  $T"
        echo -e "${lm}"

        # Fetch and display messages
        msg=$(curl -s "$URL/messages" | jq -r '.[] | "\(.username): \(.message)"')
        echo -e "${g}$msg"
        
        # Fetch and display ads
        ads=$(curl -s "$URL/ads" | jq -r '.[]')
        echo -e "${c}$ads${c}\n"

        # Function to send a message
        read -p "[+]─[Enter Message | $username]──➤ " message
        if [[ "$message" == $'q' ]]; then
        echo
    echo -e "\n ${E} ${r}Exiting..Tool..!\n"
                    sleep 1
 if [ $random_number -eq 0 ]; then
    goodbye
else
    broken
fi
    break
       else
            curl -s -X POST -H "Content-Type: application/json" -d "{\"username\":\" 〄 $username\", \"message\":\"$message\"}" "$URL/send" &> /dev/null
        fi
    done
}

mkdir -p "$USERNAME_DIR"

save_username() {
    clear
    load
echo -e "        ${c}____    __    ____  _  _     _  _ "
echo -e "       ${c}(  _ \  /__\  (  _ \( )/ )___( \/ )"
echo -e "       ${y} )(_) )/(__)\  )   / )  ((___))  ("
echo -e "      ${y} (____/(__)(__)(_)\_)(_)\_)   (_/\_)\n\n"
    echo -e " ${A} ${c}Enter Your Anonymous ${g}Username${c}"
    echo
    read -p "[+]──[Enter Your Username]────► " username

    # Validate username
    if [[ -z "$username" ]]; then
        echo -e "${r}Username cannot be empty!${n}"
        save_username
        return
    fi

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
    echo -e " ${D} ${c}Enjoy Our Chat Tool¡"
    echo
    read -p "[+]──[Enter to back]────► "
    dx
    display_messages
}

# Load username if exists
if [ -f "$USERNAME_FILE" ]; then
    username=$(cat "$USERNAME_FILE")
else
    save_username
    username=$(cat "$USERNAME_FILE")
fi

# Start displaying messages
inter
display_messages
