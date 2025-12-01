# ==============================================================================
# 1. ZSH FRAMEWORK AND PLUGIN INITIALIZATION (codex_zshrc_base.sh)
#    This file contains all static configuration, aliases, and theme setup.
# ==============================================================================

# --- FRAMEWORK ---
export ZSH=$HOME/.oh-my-zsh
ZSH_THEME="codex" # Assumes 'codex.zsh-theme' is installed (Your custom theme)

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

# Source Oh-My-Zsh core
source $ZSH/oh-my-zsh.sh

# Explicitly source plugins (Optional but robust for custom setups)
# These lines ensure plugins are loaded even if OMZ fails to load them correctly.
source $HOME/.oh-my-zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null
source $HOME/.oh-my-zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null


# --- ADVANCED ALIASES ---
# Modern replacements for ls
alias ls='lsd'
alias la='lsd -lha --blocks size,name' # List all, human-readable, detailed
alias ll='lsd -lha --group-dirs first' # Group directories first

# System/Tool aliases
alias top='htop' # Advanced process viewer
alias cat='bat --paging=never --style=header,grid' # Modern file content viewer
alias edit='nano' # Simple editor alias

# Codex specific aliases
# NOTE: Pathing corrected to match standard Termux/user structure
alias dev='bash $HOME/.CODEX/dev.sh'
alias report='bash $HOME/.CODEX/report.sh' 
alias rd='termux-reload-settings'


# --- ENVIRONMENT VARIABLES & PATHS ---
# Directory for custom files
export CODEX_CUSTOM_DIR="$HOME/.termux"
# Path to the cached version file
export CODEX_VERSION_FILE="$CODEX_CUSTOM_DIR/dx.txt"
# Path to the cached ads file
export CODEX_ADS_FILE="$CODEX_CUSTOM_DIR/ads.txt"


# --- STARTUP HOOK ---
# Execute the heavy startup script ONLY ONCE per shell session.
if [[ -z "$CODEX_BANNER_SHOWN" ]]; then
    export CODEX_BANNER_SHOWN="1"
    
    # Check for dependencies needed by the banner script before running
    if command -v figlet >/dev/null && command -v lolcat >/dev/null; then
        # Run the banner script
        bash $HOME/.CODEX/codex_startup_banner.sh
    else
        echo -e "\n\e[31m[!] Missing Dependencies: figlet or lolcat. Skipping animated banner.\e[0m"
    fi
fi

