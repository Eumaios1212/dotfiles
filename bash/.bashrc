# ~/.bashrc  – executed by bash(1) for non‑login shells

###############################################################################
# 1. Early exit for non‑interactive shells
###############################################################################
# ─── Ensure /usr/local/bin is in root's PATH ────────────────────────────────
if [ "$(id -u)" -eq 0 ] && ! printf '%s\n' "$PATH" | grep -q '/usr/local/bin'; then
    PATH="/usr/local/bin:$PATH"
fi

case $- in
    *i*) ;;      	# interactive
      *) return;;	# non‑interactive
esac

# ─── Source ble.sh with --noattach for interactive shells ───────────────────
[[ $- == *i* ]] && source ~/.local/share/blesh/ble.sh --noattach

###############################################################################
# 2. Environment variables
###############################################################################
export EDITOR="nano"
export VISUAL="nano"
# Let each terminal set its own TERM (kitty=xterm-kitty, gnome=xterm-256color)
# Only force 256color as fallback for terminals that don't set it properly
[[ -z "$TERM" || "$TERM" == "dumb" ]] && export TERM=xterm-256color
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# Add ~/bin to PATH
PATH="$HOME/bin:$PATH"

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh"          ] && . "$NVM_DIR/nvm.sh"

###############################################################################
# 3. Load Personal Libraries
###############################################################################
[ -f ~/.bash_functions ] && . ~/.bash_functions
[ -f ~/.bash_aliases   ] && . ~/.bash_aliases

###############################################################################
# 4. History configuration
###############################################################################
export HISTCONTROL=ignorespace:erasedups	# no dupes; ignore leading‑space
HISTSIZE=1000
HISTFILESIZE=2000
HISTTIMEFORMAT="%Y-%m-%d %T "			# timestamps in history
shopt -s histappend				# append rather than overwrite
export PROMPT_COMMAND='history -a; history -n'

###############################################################################
# 4b. Terminal title (for kitty tabs)
###############################################################################
# Prevent Claude Code from overwriting the terminal title at startup
export CLAUDE_CODE_DISABLE_TERMINAL_TITLE=1

# Set terminal/tab title to this server's IP address via OSC 0 escape sequence
__set_terminal_title() {
    local ip
    ip=$(hostname -I 2>/dev/null | awk '{print $1}')
    [[ -n "$ip" ]] && printf '\033]0;%s\007' "$ip"
}
[[ "$PROMPT_COMMAND" != *__set_terminal_title* ]] && \
    PROMPT_COMMAND="__set_terminal_title${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

###############################################################################
# 5. Shell options
###############################################################################
shopt -s cdspell       # fix minor cd typos
shopt -s checkwinsize  # auto‑resize LINES/COLUMNS
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

###############################################################################
# 6. Debian chroot detection
###############################################################################
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

###############################################################################
# 7. Prompt configuration (Git-Aware)
###############################################################################
# Enable colour prompt on colour terminals
#case "$TERM" in xterm-color|*-256color) color_prompt=yes;; esac
#if [ -n "$force_color_prompt" ] && tput setaf 1 >&/dev/null; then
#    color_prompt=yes
#fi

# Colour variables
#BOLD_RED="\[\033[1;31m\]"
#BOLD_GREEN="\[\033[1;32m\]"
#BOLD_YEL="\[\033[1;93m\]"
#BOLD_BLU="\[\033[1;94m\]"
#RESET="\[\033[0m\]"

# Window title
#PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"; '"$PROMPT_COMMAND"

# Build PS1 (uses parse_git_branch / parse_git_status from ~/.bash_functions)
#export PS1="${BOLD_GREEN}\u${BOLD_YEL}@\h${BOLD_BLU}:\w"\
#"${BOLD_YEL}\$(parse_git_branch)"\
#"${BOLD_RED}\$(parse_git_status)"\
#"${RESET}\$ "

# Title fix for xterm / rxvt
#case "$TERM" in
#xterm*|rxvt*)
#    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
#    ;;
#esac

###############################################################################
# 8. Colour support for ls / grep
###############################################################################
if command -v dircolors &>/dev/null; then
    eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

###############################################################################
# 9. GCC coloured diagnostics
###############################################################################
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

###############################################################################
# 10. Alert alias & user aliases
###############################################################################
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" \
"$(history|tail -n1|sed -e '\''s/^\\s*[0-9]\\+\\s*//;s/[;&|]\\s*alert$//'\'')"'

###############################################################################
# 11. Programmable completion (enable, if not using ble.sh autocompletion)
###############################################################################
#if ! shopt -oq posix; then
#  if   [ -f /usr/share/bash-completion/bash_completion ]; then
#       . /usr/share/bash-completion/bash_completion
#  elif [ -f /etc/bash_completion ]; then
#       . /etc/bash_completion
#  fi
#fi

###############################################################################
# 12. Host‑Specific Overrides
###############################################################################
[ -f ~/.bashrc.local ] && . ~/.bashrc.local

# ─── Conda initialise ─────────────────────────────────────────────────────────
if [ -f "$HOME/anaconda3/etc/profile.d/conda.sh" ]; then
# source "$HOME/anaconda3/etc/profile.d/conda.sh"  # commented out by conda initialize
    __conda_setup="$("$HOME/anaconda3/bin/conda" shell.bash hook 2>/dev/null)"
    eval "$__conda_setup"
    unset __conda_setup
fi
# ───────────────────────────────────────────────────────────────────────────────
###############################################################################
# 13. Starship
###############################################################################
export STARSHIP_CONFIG="$HOME/.config/starship.toml"
if command -v starship &>/dev/null; then
    eval "$(starship init bash)"
fi
#eval "$(starship init bash)"      # ← NOTHING must come after this

###############################################################################
# 14. Attach ble.sh after all other configurations, including Starship.
###############################################################################
[[ ! ${BLE_VERSION-} ]] || ble-attach

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
# Robust version: prefers Miniconda3 if present, otherwise falls back to Anaconda

if [ -x "$HOME/miniconda3/bin/conda" ]; then
    # Miniconda3 installation
    __conda_setup="$('$HOME/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        . "$HOME/miniconda3/etc/profile.d/conda.sh" 2>/dev/null || true
    fi
elif [ -x "$HOME/anaconda3/bin/conda" ]; then
    # Anaconda installation
    __conda_setup="$('$HOME/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        . "$HOME/anaconda3/etc/profile.d/conda.sh" 2>/dev/null || true
    fi
else
    # No Conda installation detected; add potential paths as fallback
    export PATH="$HOME/miniconda3/bin:$HOME/anaconda3/bin:$PATH"
fi
unset __conda_setup
# <<< conda initialize <<<

# pnpm
export PNPM_HOME="/home/eumaios/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
export GPG_TTY=$(tty)
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
