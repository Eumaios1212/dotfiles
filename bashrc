# ~/.bashrc  – executed by bash(1) for non‑login shells
###############################################################################
# 1. Early exit for non‑interactive shells
###############################################################################
case $- in
    *i*) ;;      # interactive
      *) return;;# non‑interactive
esac

###############################################################################
# 2. Environment variables
###############################################################################
export EDITOR="nano"
export VISUAL="nano"

# Add ~/bin to PATH
PATH="$HOME/bin:$PATH"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh"          ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

###############################################################################
# 3. Source personal function library
###############################################################################
if [ -f "$HOME/.bash_functions" ]; then
    . "$HOME/.bash_functions"
fi

###############################################################################
# 4. History configuration
###############################################################################
export HISTCONTROL=ignorespace:erasedups
HISTSIZE=1000
HISTFILESIZE=2000
HISTTIMEFORMAT="%Y-%m-%d %T "
shopt -s histappend
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

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
# 7. Prompt configuration (base colours; Git details come from bash_functions)
###############################################################################
case "$TERM" in xterm-color|*-256color) color_prompt=yes;; esac

if [ -n "$force_color_prompt" ] && tput setaf 1 >&/dev/null; then
    color_prompt=yes
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\
\[\033[01;32m\]\u\[\033[0m\]\
\[\033[01;93m\]@\[\033[0m\]\
\[\033[01;93m\]\h\[\033[0m\]:\
\[\033[01;94m\]\w\[\033[0m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# xterm / rxvt window title
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
esac

###############################################################################
# 8. Colour support for ls / grep
###############################################################################
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" \
                          || eval "$(dircolors -b)"
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

[ -f ~/.bash_aliases ] && . ~/.bash_aliases

###############################################################################
# 11. Programmable completion
###############################################################################
if ! shopt -oq posix; then
  if   [ -f /usr/share/bash-completion/bash_completion ]; then
       . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
       . /etc/bash_completion
  fi
fi

###############################################################################
# 12. Git‑aware prompt additions (functions live in bash_functions)
###############################################################################
BOLD_RED="\[\033[1;31m\]"
BOLD_GREEN="\[\033[1;32m\]"
BOLD_BRIGHT_YELLOW="\[\033[1;93m\]"
BOLD_BRIGHT_BLUE="\[\033[1;94m\]"
RESET="\[\033[0m\]"

PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'

export PS1="${BOLD_GREEN}\u${BOLD_BRIGHT_YELLOW}@\h${BOLD_BRIGHT_BLUE}:\w"\
"${BOLD_BRIGHT_YELLOW}\$(parse_git_branch)"\
"${BOLD_RED}\$(parse_git_status)"\
"${RESET}\$ "
