# ==============================================================================
# Zsh Prompt Theme Configuration: DARK-X Custom PROMPT
# Designed for Termux/Mobile environments using Nerd Fonts and termux-api.
# ==============================================================================

# --- 1. ENVIRONMENT SETUP ---
# Disable job notification immediately upon completion
unsetopt NOTIFY
# Disable job control (often unnecessary in simple scripts/prompts)
set +m

# Enable necessary prompt options
setopt PROMPT_SUBST # Enable variable substitution in prompts (critical for functions like dx_git_prompt)
setopt AUTO_CD      # If a command is a directory, automatically 'cd' into it.

# --- 2. COLOR & ICON DEFINITIONS ---
# Use standard Zsh sequence for colors (%F{...}) and attributes (%B/%b)
local blue='%F{blue}'
local cyan='%F{cyan}'
local green='%F{green}'
local yellow='%F{yellow}'
local red='%F{red}'
local white='%F{white}'
local reset='%f'
local bold='%B'
local nb='%b' # No bold

# Advanced Icons (Requires Nerd Font)
local icon_user=''     # User Icon
local icon_host=''     # Host Icon
local icon_dir=''      # Directory Icon
local icon_git=''      # Git Icon
local icon_time=''     # Clock Icon
local icon_job='⚙'      # Job Icon
local icon_battery='' # Battery Icon (Approx 75% full)
local icon_load=''     # Load/Activity Icon
local icon_status='⚡'  # For Charging

# --- 3. GIT PROMPT INTEGRATION ---

# NOTE: This relies on the 'git_prompt_info' function being sourced externally (e.g., from oh-my-zsh).

# Function to integrate Git info into the PROMPT
function dx_git_prompt() {
  # ZSH_THEME_GIT_PROMPT variables are set globally by the user's setup
  local git_info=$(git_prompt_info)
  if [[ -n "$git_info" ]]; then
    # Format: ( branch_name *[dirty])
    echo "${bold}${blue}(${icon_git} ${yellow}${git_info}${blue})${reset}"
  fi
}

# --- 4. LEFT PROMPT (PROMPT) DEFINITION ---
# Structure:
# Line 1: ┌─╼[DARK〆HACKER]
# Line 2: │  user at  host
# Line 3: └─╼  current/dir/path (Git Status)
# Line 4: Success/Error status icon (└─▶ or └─✘)
PROMPT='
${cyan}┌─╼${bold}[${blue}DARK${yellow}〆${green}HACKER${cyan}]${reset}
${cyan}│ ${bold}${icon_user} ${green}%n ${cyan}at ${bold}${icon_host} ${yellow}%m
${cyan}└─╼ ${bold}${icon_dir} ${white}%(5~|%-1~/…/%2~|%4~)${reset} $(dx_git_prompt)
%(?,${green} └─▶${reset} ,${red} └─✘${reset} ) '

# --- 5. RIGHT PROMPT (RPROMPT) SYSTEM STATUS ---

# RPROMPT components function (for idle status)
dx_rprompt_info() {
    # 1. Background Jobs Count (Display if > 0)
    local jobs_count=$(jobs -r | wc -l | tr -d ' ')

    # 2. System Load Average (1-minute load)
    local load_avg=$(cut -d' ' -f1 /proc/loadavg 2>/dev/null)
    
    # 3. Battery Status (Termux-specific, checks for command existence)
    local battery_status=""
    if command -v termux-battery-status &> /dev/null; then
        local bat_data
        bat_data=$(termux-battery-status 2>/dev/null)
        
        local bat_level=$(echo "$bat_data" | jq -r '.percentage' 2>/dev/null)
        local bat_stat=$(echo "$bat_data" | jq -r '.status' 2>/dev/null)
        
        if [[ -n "$bat_level" && "$bat_level" != "null" ]]; then
            local bat_color='%F{green}'
            local charge_icon=''
            
            if [ "$bat_level" -lt 20 ]; then bat_color='%F{red}'; fi
            if [ "$bat_level" -lt 40 ]; then bat_color='%F{yellow}'; fi

            if [[ "$bat_stat" == "CHARGING" ]]; then charge_icon=" ${icon_status}"; fi

            # Output: [ 90% ⚡]
            battery_status="${bat_color}${icon_battery} ${bat_level}%${charge_icon}${reset}"
        fi
    fi

    local status_line=""
    
    if [ -n "$load_avg" ]; then status_line+="${cyan}${icon_load} ${load_avg} ${reset} | "; fi
    if [ "$jobs_count" -gt 0 ]; then status_line+="${yellow}${icon_job} ${jobs_count} ${reset} | "; fi
    if [ -n "$battery_status" ]; then status_line+="${battery_status} | ${reset}"; fi

    # Combine all status info with the current time
    # Final Output: [Load | Jobs | Battery | Time]
    echo "${status_line}${bold}${icon_time} ${cyan}%D{%H:%M:%S}${reset}"
}

# --- 6. HOOKS (TIMER AND BACKGROUND SCRIPT) ---

# Global timer variable
local timer

# Executes before a command runs
preexec() {
    # Check if the command is a known long-running command (like package management, git, or execution)
    # The check `[[ $(echo $1 | wc -w) -ge 2 ]]` prevents starting the timer for single words (like 'ls')
    if [[ $1 =~ ^(bash|sh|python|python3|nano|vim|vi|open|pkg|apt|php|make|git|curl|wget) ]] && [[ $(echo $1 | wc -w) -ge 2 ]]; then
        timer=$(date +%s)
    fi
}

# Executes after a command finishes
precmd() {
    # 1. Background script execution (The CODEX Updater)
    # Runs the script in the background every time a prompt is redrawn.
    # The script itself handles throttling/caching (5-minute interval).
    if [ -f "$HOME/.CODEX/dx-simu.sh" ]; then
        # Run in the background using '&' and suppress all output '>& /dev/null'
        $HOME/.CODEX/dx-simu.sh &> /dev/null &
    fi

    # 2. RPROMPT Logic (Execution Time vs. Idle Status)
    if [ -n "$timer" ]; then
        # COMMAND TIMER LOGIC (RPROMPT shows execution time)
        local now=$(date +%s)
        local elapsed=$((now - timer))
        
        # Only show time if command took more than 1 second
        if [[ $elapsed -ge 1 ]]; then
            local hours=$((elapsed / 3600))
            local minutes=$(( (elapsed % 3600) / 60 ))
            local seconds=$((elapsed % 60))
            local elapsed_str=""

            if [[ $hours -gt 0 ]]; then
                elapsed_str="${cyan}${hours}h ${minutes}m ${seconds}s"
            elif [[ $minutes -gt 0 ]]; then
                elapsed_str="${cyan}${minutes}m ${seconds}s"
            else
                elapsed_str="${cyan}${seconds}s"
            fi
            
            # RPROMPT shows Run Time and Success icon
            export RPROMPT="${bold}${green}${icon_success}${reset} ${blue}Run Time:${reset} ${elapsed_str}"
        fi
        unset timer
    else
        # IDLE STATUS RPROMPT (RPROMPT shows system status)
        export RPROMPT="$(dx_rprompt_info)"
    fi
}

