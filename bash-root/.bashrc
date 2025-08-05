# ~/.bashrc (root) – minimal, interactive shell config

# Set a red prompt to distinguish root
PS1='\[\e[1;31m\]\u@\h:\w# \[\e[0m\]'

# Safer and cleaner default tools
alias ls='ls --color=auto -F'
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -h'

# Basic history behavior
HISTFILE=~/.bash_history
HISTSIZE=1000
HISTCONTROL=ignoredups:erasedups
shopt -s histappend
