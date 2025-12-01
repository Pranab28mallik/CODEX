# --- Custom Zsh Prompt Configuration (VIP Style) ---

# Load existing environment variables and functions
D1="$HOME/.termux"
r='\033[91m' # Red
p='\033[1;95m' # Purple
y='\033[93m' # Yellow
g='\033[92m' # Green
n='\033[0m'  # Reset
b='\033[94m' # Blue
c='\033[96m' # Cyan

# Define custom icons for better integration
X='${c}❌${n}' # Error/Fail
D='${y}◆${n}' # Main Logo/Separator
E='${r}${n}' # Warning/Alert
A='${g}${n}' # Success/OK
C='${c}${n}' # Prompt Icon/Command Start

# Icons from your original script
USER="\uf007"
TERMINAL="\ue7a2"
PKGS="\uf8d6"
CAL="\uf073"

# --- Zsh Options ---
unsetopt NOTIFY
set +m
setopt PROMPT_SUBST # Required for function calls and substitutions in PROMPT
setopt PROMPT_PERCENT # Allows %() syntax

# --- Function: Git Prompt Info ---
function vip_git_prompt() {
  # Check if we are in a Git repository
  if [ -d .git ]; then
    local branch_name=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    [[ -z "$branch_name" ]] && branch_name='(detached)'

    local git_status_char=' '
    # Check for uncommitted changes
    if [[ $(git status --porcelain 2>/dev/null) ]]; then
      git_status_char="${r}●${n}" # Unclean
    else
      git_status_char="${g}●${n}" # Clean
    fi
    # Format: [  main ● ]
    echo " ${b}${n} ${y}${branch_name}${n}${git_status_char}"
  fi
}
local git_segment='$(vip_git_prompt)'

# --- Function: Disk Usage Check (Simplified for Prompt) ---
function vip_disk_usage() {
    local threshold=90 # Use a slightly lower threshold for the prompt
    local used_size
    local disk_usage

    disk_usage=$(df "$HOME" | awk 'NR==2 {print $5}' | sed 's/%//g')
    used_size=$(df -h "$HOME" | awk 'NR==2 {print $3}')

    if [ "$disk_usage" -ge "$threshold" ]; then
        # Warning high disk usage
        echo "${r} ${n}${r}${disk_usage}%${n}${y} U:${used_size}${n}"
    else
        # Normal disk usage
        echo "${c} ${n}${g}${disk_usage}%${n}${y} U:${used_size}${n}"
    fi
}
local disk_segment='$(vip_disk_usage)'

# --- The Main Prompt (PROMPT) ---
# Structure: [STATUS] [USER@HOST] [CWD] [GIT]
PROMPT="
${b}┌─${n} %(!.${X}.%A) ${g}[${n}${USER}${g}] ${c}%n@%m ${b}│${n} ${p}%~ ${git_segment}
${b}└─${n} %(!.${r}.${g})${C}${n} "

# --- Dynamic Right Prompt (RPROMPT) ---
typeset -g __zsh_exec_timer

preexec() {
    # Start timer for substantial commands (retaining your original logic)
    if [[ $1 =~ ^(bash|sh|python|python3|nano|vim|vi|open|pkg|apt|php) ]] && [[ $(echo $1 | wc -w) -ge 2 ]]; then
        __zsh_exec_timer=$(date +%s)
    fi
}

precmd() {
    # Run the background script silently
    $HOME/.CODEX/dx-simu.sh &> /dev/null &

    local elapsed_str

    if [[ -n $__zsh_exec_timer ]]; then
        local now=$(date +%s)
        local elapsed=$((now - __zsh_exec_timer))
        local hours=$((elapsed / 3600))
        local minutes=$(( (elapsed % 3600) / 60 ))
        local seconds=$((elapsed % 60))

        # Format time string (h:m:s)
        if [[ $hours -gt 0 ]]; then elapsed_str+="${hours}h"; fi
        if [[ $minutes -gt 0 || $hours -gt 0 ]]; then elapsed_str+="${minutes}m"; fi
        elapsed_str+="${seconds}s"
        
        # Right Prompt with Timer
        RPROMPT="${p}[${n}${y} ${n}${g}${elapsed_str}${p}]${n}"
        unset __zsh_exec_timer
    else
        # Right Prompt with Date/Time and Disk Status
        # Format: [  HH:MM:SS | Disk ]
        local date_time="${c}%D{%L:%M:%S}%n"
        
        # Combine Time and Disk Usage
        RPROMPT="${p}[${n}${CAL}${n} ${date_time} ${c}|${n} ${disk_segment}${p}]${n}"
    fi
}
