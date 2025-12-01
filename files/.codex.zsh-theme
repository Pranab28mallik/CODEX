# --- ZSH ENVIRONMENT SETUP ---
unsetopt NOTIFY
set +m

# Enable necessary options
setopt PROMPT_SUBST
setopt AUTO_CD

# --- COLOR & ICON DEFINITIONS ---
# Use standard Zsh sequence for colors (%F{...})
local blue='%F{blue}'
local cyan='%F{cyan}'
local green='%F{green}'
local yellow='%F{yellow}'
local red='%F{red}'
local white='%F{white}'
local reset='%f'
local bold='%B'
local nb='%b'

# Advanced Icons (Requires Nerd Font to display correctly)
local icon_user=''     # User Icon
local icon_host=''     # Host Icon
local icon_dir=''      # Directory Icon
local icon_git=''      # Git Icon
local icon_time=''     # Clock Icon
local icon_success='' # Checkmark
local icon_error=''   # Error Cross
local icon_job='⚙'      # Job Icon
local icon_battery='' # Battery Icon
local icon_load=''     # Load/Activity Icon
local icon_status='⚡'  # For Charging

# --- GIT PROMPT CONFIGURATION ---

# Git status configuration variables
ZSH_THEME_GIT_PROMPT_PREFIX='${bold}${blue}(${icon_git} '
ZSH_THEME_GIT_PROMPT_SUFFIX=')'
ZSH_THEME_GIT_PROMPT_DIRTY=' *'
ZSH_THEME_GIT_PROMPT_CLEAN=' '
ZSH_THEME_GIT_PROMPT_UNTRACKED='?'

# Function to integrate Git info into the PROMPT
function dx_git_prompt() {
  local git_info=$(git_prompt_info)
  if [[ -n "$git_info" ]]; then
    # Output: ( master *) or ( master )
    echo "${ZSH_THEME_GIT_PROMPT_PREFIX}${yellow}%b%F{yellow}${git_info}${reset}${bold}${blue}${ZSH_THEME_GIT_PROMPT_SUFFIX}${reset}"
  fi
}

# --- LEFT PROMPT (PROMPT) DEFINITION ---
PROMPT='
${cyan}┌─╼${bold}[${blue}DARK${yellow}〆${green}HACKER${cyan}]${reset}
${cyan}│ ${bold}${icon_user} ${green}%n ${cyan}at ${bold}${icon_host} ${yellow}%m
${cyan}└─╼ ${bold}${icon_dir} ${white}%(5~|%-1~/…/%2~|%4~)${reset} $(dx_git_prompt)
%(?,${green} └─▶${reset} ,${red} └─✘${reset} ) '

# --- RIGHT PROMPT (RPROMPT) SYSTEM STATUS ---

# RPROMPT components function (for idle status)
dx_rprompt_info() {
    # 1. Background Jobs Count
    local jobs_count=$(jobs -r | wc -l | tr -d ' ')

    # 2. System Load Average (first value from /proc/loadavg)
    local load_avg=$(cut -d' ' -f1 /proc/loadavg 2>/dev/null)
    
    # 3. Battery Status (requires termux-api)
    local battery_status=""
    if command -v termux-battery-status &> /dev/null; then
        local bat_level=$(termux-battery-status | jq -r '.percentage' 2>/dev/null)
        local bat_stat=$(termux-battery-status | jq -r '.status' 2>/dev/null)
        
        if [ -n "$bat_level" ]; then
            local bat_color='%F{green}'
            local charge_icon=''
            if [ "$bat_level" -lt 20 ]; then bat_color='%F{red}'; fi
            if [[ "$bat_stat" == "CHARGING" ]]; then charge_icon=" ${icon_status}"; fi

            # Output: [ 90% ⚡]
            battery_status="${bat_color}${icon_battery} ${bat_level}%${charge_icon}${reset}"
        fi
    fi

    local status_line=""
    if [ -n "$load_avg" ]; then status_line+="${cyan}${icon_load} ${load_avg} ${reset}"; fi
    if [ "$jobs_count" -gt 0 ]; then status_line+="${yellow}${icon_job} ${jobs_count} ${reset}"; fi
    if [ -n "$battery_status" ]; then status_line+="${battery_status} ${reset}"; fi

    # Combine static info: [Load] [Jobs] [Battery] [Time]
    echo "${status_line} ${bold}${icon_time} ${cyan}%D{%H:%M:%S}${reset}"
}

# --- HOOKS FOR TIMER AND RPROMPT ---

# Global timer variable
local timer

# Timer and script execution before command runs
preexec() {
    # Start timer only for specific commands that typically run long
    if [[ $1 =~ ^(bash|sh|python|python3|nano|vim|vi|open|pkg|apt|php|make|git|curl|wget) ]] && [[ $(echo $1 | wc -w) -ge 2 ]]; then
        timer=$(date +%s)
    fi
}

# Command run after command finishes
precmd() {
    # Run the custom script in the background (maintaining original request)
    if [ -f "$HOME/.CODEX/dx-simu.sh" ]; then
        $HOME/.CODEX/dx-simu.sh &> /dev/null &
    fi

    if [ -n "$timer" ]; then
        # COMMAND TIMER LOGIC
        local now=$(date +%s)
        local elapsed=$((now - timer))
        local hours=$((elapsed / 3600))
        local minutes=$(( (elapsed % 3600) / 60 ))
        local seconds=$((elapsed % 60))
        local elapsed_str=""

        # Format the time display
        if [[ $hours -gt 0 ]]; then
            elapsed_str="${cyan}${hours}h ${minutes}m ${seconds}s"
        elif [[ $minutes -gt 0 ]]; then
            elapsed_str="${cyan}${minutes}m ${seconds}s"
        else
            elapsed_str="${cyan}${seconds}s"
        fi

        # RPROMPT displays execution time and success icon
        export RPROMPT="${bold}${green}${icon_success}${reset} ${blue}Run Time:${reset} ${elapsed_str}"
        unset timer
    else
        # IDLE STATUS RPROMPT
        export RPROMPT="$(dx_rprompt_info)"
    fi
}
