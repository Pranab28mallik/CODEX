# --- Configuration Flags ---
unsetopt NOTIFY
set +m
setopt PROMPT_SUBST # Needed for substitution in the prompt

# --- Color Definitions and Gradient Helpers ---
# We'll use a deep background color for the main bar and a lighter one for the input line
# Note: %B/%b for bolding, %K{...}/%k for background color

# Status Bar Background Color (Dark Blue/Gray)
local BG_BAR='%K{#1E1E2E}'
local FG_TEXT='%F{#FFFFFF}'

# Input Line Background Color (Slightly Lighter Gray)
local BG_INPUT='%K{#282A36}'

# Separator icon (Nerd Font: PL Right Block)
local SEP_RIGHT=''

# Status Indicator (Success/Error)
local status_indicator='%(!.%F{#FF5555}.%F{#50FA7B})%f' 

# --- Dynamic Prompt Components ---

# 1. User & Host Segment: [  user@host ]
local user_host_segment="${FG_TEXT} %F{#BD93F9}%n@%m%f"

# 2. Directory Segment: [  /path/to/dir ]
# Uses %1~ (basename) for brevity in the bar
local dir_segment="${FG_TEXT} %F{#F1FA8C}%1~%f"

# 3. Git Segment: [  branch <status> ]
function git_prompt_info() {
  if [ -d .git ]; then
    local branch_name=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    [[ -z "$branch_name" ]] && branch_name='(detached)'

    local git_status_char=' '
    # Check for uncommitted changes
    if [[ $(git status --porcelain 2>/dev/null) ]]; then
      git_status_char='%F{#FF5555}%f' # Unclean (Dirt)
    else
      git_status_char='%F{#50FA7B}%f' # Clean (Pencil)
    fi
    # Format:  main <status>
    echo " ${FG_TEXT} %F{#8BE9FD}${branch_name}%f ${git_status_char}"
  fi
}
local git_segment='$(git_prompt_info)'

# 4. Battery Status (Linux/macOS compatible placeholder)
# NOTE: This uses the simple Zsh $battery_level if available, or a fallback.
local bat_segment='${FG_TEXT}%f %F{#50FA7B}${battery_level}%f' # Requires Zsh battery module or similar setup

# --- The Main Prompt (PROMPT) ---

# Construct the top status bar (in dark BG)
PROMPT="
${BG_BAR}%B%F{#BD93F9}${SEP_RIGHT}${user_host_segment} %F{#FF79C6}${SEP_RIGHT} ${dir_segment} %F{#BD93F9}${SEP_RIGHT}${git_segment} %F{#FF79C6}${SEP_RIGHT} %F{#50FA7B}%(5~|%-1~/…/%2~|%4~)%f
${BG_INPUT}%B%F{#282A36}${SEP_RIGHT}%F{#FF79C6}%F{#FFFFFF} INPUT%f ${status_indicator} 
${BG_INPUT} %F{#FF79C6}❯%F{#50FA7B}❯%F{#F1FA8C}❯%f%b%k "

# Remove the background from the last line when typing (optional, but cleaner)
PROMPT=$PROMPT'%k'

# --- Dynamic Right Prompt (RPROMPT) for Time/Execution ---

typeset -g __zsh_exec_timer

preexec() {
    # Start timer for substantial commands
    if [[ $1 =~ ^(bash|sh|python|python3|nano|vim|vi|open|pkg|apt|php) ]] && [[ $(echo $1 | wc -w) -ge 2 ]]; then
        __zsh_exec_timer=$(date +%s)
    fi
}

precmd() {
    # Your background script
    # $HOME/.CODEX/dx-simu.sh &> /dev/null &

    local elapsed_str
    local RPROMPT_BG='%K{#1E1E2E}'
    local RPROMPT_SEP='%F{#BD93F9}' # Left Block Separator (reversed)

    if [[ -n $__zsh_exec_timer ]]; then
        local now=$(date +%s)
        local elapsed=$((now - __zsh_exec_timer))
        local hours=$((elapsed / 3600))
        local minutes=$(( (elapsed % 3600) / 60 ))
        local seconds=$((elapsed % 60))

        # Format time string
        if [[ $hours -gt 0 ]]; then
            elapsed_str="%F{#8BE9FD}${hours}h"
            [[ $minutes -gt 0 ]] && elapsed_str+="%F{#FF79C6}${minutes}m"
        elif [[ $minutes -gt 0 ]]; then
            elapsed_str="%F{#8BE9FD}${minutes}m"
            [[ $seconds -gt 0 ]] && elapsed_str+="%F{#FF79C6}${seconds}s"
        else
            elapsed_str="%F{#FF79C6}${seconds}s"
        fi
        
        # Right Prompt with Timer
        RPROMPT="${RPROMPT_SEP}${RPROMPT_BG}%F{#FFFFFF} %f ${elapsed_str} %k"
        unset __zsh_exec_timer
    else
        # Right Prompt with Date/Time
        # Format:  MM/DD  HH:MM:SS
        local date_time="%F{#BD93F9}%f %F{#F1FA8C}%D{%m/%d}%f %F{#BD93F9}%f %F{#8BE9FD}%D{%L:%M:%S}%f"

        RPROMPT="${RPROMPT_SEP}${RPROMPT_BG} ${date_time} %k"
    fi
}
