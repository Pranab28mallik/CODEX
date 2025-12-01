#!/usr/bin/env zsh
# =========================================================================
# ZSH Theme: CODEX Advanced (v3.0 - Gemini Enhanced)
# Purpose: Clean, modern, two-line prompt with command timing and status
# =========================================================================

# --- 1. CONFIGURATION AND SETTINGS ---

unsetopt NOTIFY
set +m
setopt PROMPT_SUBST

# Define colors for better readability (Standard ANSI & Termux-friendly)
local R="%{$fg[red]%}"
local G="%{$fg[green]%}"
local B="%{$fg[blue]%}"
local C="%{$fg[cyan]%}"
local Y="%{$fg[yellow]%}"
local P="%{$fg[magenta]%}"
local W="%{$fg[white]%}"
local GR="%{$fg[gray]%}"
local N="%{$reset_color%}"

# Define Symbols (Unicode/Emoji)
local SYM_TIME="${GR}⏱${N}"
local SYM_DIR="${C}${N}" # Folder icon
local SYM_GIT="${P}${N}" # Git icon
local SYM_PROMPT="${G}❯${N}"
local SYM_ERR="${R}✗${N}"
local SYM_OK="${G}✓${N}"

# --- 2. GIT STATUS FUNCTION ---

# Simple function to get a clean, faster git status display
git_prompt_info() {
    local git_status
    git_status=$(command git status --porcelain 2>/dev/null)
    
    # Check if we are in a Git repository
    if [ -n "$(command git rev-parse --is-inside-work-tree 2>/dev/null)" ]; then
        local branch_name
        branch_name=$(command git rev-parse --abbrev-ref HEAD 2>/dev/null)
        
        local status_symbol=""
        if [[ -n $git_status ]]; then
            status_symbol="${Y} *${N}" # Modified/Staged
        elif command git status --porcelain=v1 2>/dev/null | grep -q '^\(A\|D\|U\)'; then
             status_symbol="${Y} *${N}" # Any change
        fi

        echo "${SYM_GIT} ${P}${branch_name}${status_symbol}${N}"
    fi
}


# --- 3. PROMPT DEFINITION (TWO-LINE MODERN) ---

PROMPT="
# First Line: User, Host, Directory, Git, and Exit Status
${G}┌─[${B}%n${G}@${B}%m${G}]─${N}${SYM_DIR} ${W}%(5~|%-1~/…/%2~|%4~)${N} \
\$(git_prompt_info)\
%{\$fg[yellow]%} \$(if [[ \$? -ne 0 ]]; then echo "${SYM_ERR} \$?"; else echo "${SYM_OK}"; fi)%{\$reset_color%}
# Second Line: Prompt Arrow (or Symbol)
${G}└─${SYM_PROMPT} ${N}"

# --- 4. PRE/POST COMMAND HOOKS (TIMER & RPROMPT) ---

# Variable to store the start time
local timer

# Executes right before command execution
preexec() {
    # Check for interactive commands (like bash, sh, compilers, etc.)
    if [[ $1 =~ ^(bash|sh|python|python3|nano|vim|vi|open|pkg|apt|php|git|ssh) ]] && [[ $(echo $1 | wc -w) -ge 1 ]]; then
        timer=$(date +%s%3N) # Store time in milliseconds for precision
    fi
}

# Executes right before prompt display
precmd() {
    # Run the background script silently (if it exists)
    $HOME/.CODEX/dx-simu.sh &> /dev/null &

    local elapsed_str=""
    if [ $timer ]; then
        local now=$(date +%s%3N)
        local elapsed=$((now - timer)) # Milliseconds

        # Convert milliseconds to H:M:S format
        local ms=${elapsed}
        local seconds=$((ms / 1000))
        local milliseconds=$((ms % 1000))
        
        local hours=$((seconds / 3600))
        local minutes=$(( (seconds % 3600) / 60 ))
        local remaining_seconds=$((seconds % 60))

        # Format output string
        if [[ $hours -gt 0 ]]; then
            elapsed_str="${C}${hours}h ${minutes}m ${remaining_seconds}s"
        elif [[ $minutes -gt 0 ]]; then
            elapsed_str="${C}${minutes}m ${remaining_seconds}s"
        else
            # Show seconds and milliseconds if time is short
            elapsed_str="${C}${remaining_seconds}.${milliseconds}s"
        fi
        
        # Right Prompt: Show Timer
        export RPROMPT="${SYM_TIME} ${GR}Time:${N} ${elapsed_str}"
        unset timer
    else
        # Right Prompt: Show current time/date
        export RPROMPT="${SYM_TIME} ${GR}%D{%a %b %d} ${C}%D{%I:%M:%S %p}${N}"
    fi
    
    # Clean up the timing variable at the end
    unset elapsed_str
}
