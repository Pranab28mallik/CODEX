# Disable notification alerts
unsetopt NOTIFY
# Disable job control
set +m

# Define current directory prompt with color formatting
local current_dir='%{$fg_bold[red]%}[%{$reset_color%}~%{$fg_bold[red]%}]%{$reset_color%}'

# Initialize git branch variable (can be customized to fetch actual branch)
local git_branch='$()%{$reset_color%}'

# Define the main prompt with styling and dynamic info
PROMPT='
%(?,%{$fg_bold[cyan]%} ┌─╼%{$fg_bold[cyan]%}[%{$fg_bold[blue]%}PNB28%{$fg_bold[yellow]%}〄%{$fg_bold[green]%}D1D4X%{$fg_bold[cyan]%}]%{$fg_bold[cyan]%}-%{$fg_bold[cyan]%}[%{$fg_bold[green]%}%(5~|%-1~/…/%2~|%4~)%{$fg_bold[cyan]%}]%{$reset_color%} ${git_branch}
%{$fg_bold[cyan]%} └────╼%{$fg_bold[yellow]%} ❯%{$fg_bold[blue]%}❯%{$fg_bold[cyan]%}❯%{$reset_color%} ,%{$fg_bold[cyan]%} ┌─╼%{$fg_bold[cyan]%}[%{$bold[green]%}%(5~|%-1~/…/%2~|%4~)%{$reset_color}]%{$reset_color%}'

# Git prompt prefix and suffix for branch info
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}["
ZSH_THEME_GIT_PROMPT_SUFFIX="] %{$reset_color%}"

# Enable prompt substitution
setopt PROMPT_SUBST
# Bind Ctrl+R to reset the prompt
bindkey '^R' reset-prompt

# Timing function for measuring command duration
preexec() {
    if [[ $1 =~ ^(bash|sh|python|python3|nano|vim|vi|open|pkg|apt|php) ]] && [[ $(echo $1 | wc -w) -ge 2 ]]; then
        timer=$(date +%s)
    fi
}

# Pre-command prompt function to display elapsed time or current time
precmd() {
    if [ $timer ]; then
        now=$(date +%s)
        elapsed=$((now - timer))
        hours=$((elapsed / 3600))
        minutes=$(((elapsed % 3600) / 60))
        seconds=$((elapsed % 60))

        # Format elapsed time
        if [[ $hours -gt 0 ]]; then
            if [[ $minutes -gt 0 ]]; then
                elapsed_str="%F{blue}Run time:%f %F{cyan}${hours}%f h %F{cyan}${minutes}%f m"
            else
                elapsed_str="%F{blue}Run time:%f %F{cyan}${hours}%f h"
            fi
        elif [[ $minutes -gt 0 ]]; then
            if [[ $seconds -gt 0 ]]; then
                elapsed_str="%F{blue}Run time:%f %F{cyan}${minutes}%f m %F{cyan}${seconds}%f s"
            else
                elapsed_str="%F{blue}Run time:%f %F{cyan}${minutes}%f m"
            fi
        else
            elapsed_str="%F{blue}Run time:%f %F{cyan}${seconds}%f s"
        fi

        # Display elapsed time in right prompt
        export RPROMPT='%F{green}[%f⏱%F{green}]%f ${elapsed_str}'
        unset timer
    else
        # Default right prompt with current time and context
        unset elapsed_str
        export RPROMPT='%F{green}[%f%F{green}]%f %F{cyan}%D{%L:%M:%S}%f%F{white} - %f%F{cyan}%D{%p}%f'
    fi
}
