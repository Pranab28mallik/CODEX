unsetopt NOTIFY
set +m

# --- Configuration for Prompt ---
# Use different colors for a high-contrast, cyberpunk feel
local V_SEP='%{$fg_bold[magenta]%}:%{$reset_color%}' # Vertical separator
local L_ARROW='%{$fg_bold[cyan]%}❮%{$reset_color%}' # Left arrow
local R_ARROW='%{$fg_bold[cyan]%}❯%{$reset_color%}' # Right arrow
local PROMPT_ROOT_CHAR='%{$fg_bold[red]%}#%{$reset_color%}' # Root prompt character
local PROMPT_USER_CHAR='%{$fg_bold[yellow]%}»%{$reset_color%}' # User prompt character

# The PROMPT variable is what's displayed before the command line
PROMPT="
%{$fg_bold[magenta]%}┌─${R_ARROW}%{$fg_bold[blue]%} %n@%m %{$fg_bold[magenta]%} ${V_SEP} %{$fg_bold[white]%} ${L_ARROW}%(5~|%-1~/…/%2~|%4~)%{$fg_bold[white]%} ${R_ARROW}%{$reset_color%}
%{$fg_bold[magenta]%}└─${R_ARROW}%{$fg_bold[blue]%}${PROMPT_USER_CHAR}%{$reset_color%} " # The final prompt line

# Use a different prompt for root user (e.g., if you run 'sudo -i')
PROMPT='${PROMPT_USER_CHAR}'
if [[ $UID -eq 0 ]]; then
    PROMPT='${PROMPT_ROOT_CHAR}'
fi

PROMPT="
%{$fg_bold[magenta]%}┌─${R_ARROW}%{$fg_bold[blue]%} %n@%m %{$fg_bold[magenta]%} ${V_SEP} %{$fg_bold[white]%} %~ %{$fg_bold[magenta]%} ${V_SEP} %{$fg_bold[yellow]%}${git_branch}%{$reset_color%}
%{$fg_bold[magenta]%}└─${R_ARROW}%{$PROMPT} "

# --- Git Prompt Customization ---
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[yellow]%}git:%{$fg_bold[cyan]}["
ZSH_THEME_GIT_PROMPT_SUFFIX="]%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg_bold[red]%} *%{$reset_color%}" # Asterisk for dirty
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg_bold[yellow]%} ?%{$reset_color%}" # Question mark for untracked

# --- Prompt Settings and Keybindings ---
setopt PROMPT_SUBST # Required for variables and command substitution in PROMPT
bindkey '^R' reset-prompt

# --- Execution Time Tracking (preexec and precmd) ---
# Runs *before* command execution
preexec() {
    # Check for specific commands with arguments (original logic)
    if [[ $1 =~ ^(bash|sh|python|python3|nano|vim|vi|open|pkg|apt|php) ]] && [[ $(echo $1 | wc -w) -ge 2 ]]; then
        timer=$(date +%s)
    fi
}

# Runs *before* the prompt is displayed
precmd() {
    # Original dx-simu script execution
    $HOME/.CODEX/dx-simu.sh &> /dev/null &

    if [ $timer ]; then
        now=$(date +%s)
        elapsed=$((now - timer))
        
        # New: Use a single helper function for formatting time
        local format_time
        format_time() {
            local seconds=$1
            local hours=$((seconds / 3600))
            local minutes=$(( (seconds % 3600) / 60 ))
            local secs=$((seconds % 60))
            
            local result=""
            if [[ $hours -gt 0 ]]; then
                result+="%{$fg_bold[red]%}${hours}h%{$reset_color%} "
            fi
            if [[ $minutes -gt 0 || ($hours -gt 0 && $secs -gt 0) ]]; then
                result+="%{$fg_bold[yellow]%}${minutes}m%{$reset_color%} "
            fi
            if [[ $secs -gt 0 || ($hours -eq 0 && $minutes -eq 0) ]]; then
                result+="%{$fg_bold[cyan]%}${secs}s%{$reset_color%}"
            fi
            echo "$result"
        }

        # Set RPROMPT with the formatted run time
        local elapsed_str=$(format_time $elapsed)
        export RPROMPT="%{$fg_bold[green]%}[%{$reset_color%}⚡ RUN TIME %{$fg_bold[green]%}]:%{$reset_color%} ${elapsed_str}"
        unset timer
    else
        # Default RPROMPT with a stylized clock and date/time
        unset elapsed_str
        export RPROMPT="%{$fg_bold[magenta]%}[%{$fg_bold[blue]%}◷%{$fg_bold[magenta]%]%{$reset_color%} %{$fg_bold[cyan]%}%D{%H:%M:%S}%{$reset_color%} %{$fg_bold[magenta]%}—%{$reset_color%} %{$fg_bold[white]%}%D{%d %b}%{$reset_color%}"
    fi
}
