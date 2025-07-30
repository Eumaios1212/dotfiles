
# My Custom Aliases

# Function for updates, since sudo is needed for apt, should not be used with pipx:
update() {
    # --- OS packages ---
    sudo apt update           # refresh package lists
    sudo apt upgrade -y       # upgrade packages
    sudo apt autoremove -y    # clean leftovers

    # --- pipx packages ---
    pipx upgrade-all --include-injected
}

alias l='ls -ahlF --color=auto'
	#    -a: Show all files (including hidden files whose names begin with a dot).
	#    -h: Display file sizes in human-readable format (e.g., KB, MB instead of just bytes).
	#    -l: Use the long listing format (shows permissions, owner, size, modification date, etc.).
	#    -F: Append an indicator (like / for directories, * for executables) to entries.
	#    --color=auto: Colorize the output based on file type, but only if the output is to a terminal (not when piped).

alias ls='ls -CF'
	#    -C: Format the output in columns.
	#    -F: Classify file types by appending indicators to filenames (like / for dir, * for executables, @ for sym. links, etc.).

alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'
	#    -i: Run interactively, to avoid mistakenly overwriting/deleting files.

alias n='nano'
alias sn='sudo nano'

# Git aliases
alias g='git'
alias ga='git add .'
alias gc='git commit -m'
alias gd='git diff'
alias gpl='git pull'
alias gps='git push'
alias gst='git status'

# Various
alias pipe='systemctl --user restart pipewire pipewire-pulse'

###############################################################################
# 9. Alerts & Other Aliases
###############################################################################
alias alert='notify‑send …'
alias openports='netstat -nape --inet'   # show open TCP/UDP ports

# aliases to show disk space and space used in a folder
alias diskspace="du -S | sort -n -r |more"
alias folders='du -h --max-depth=1'
alias folderssort='find . -maxdepth 1 -type d -print0 | xargs -0 du -sk | sort -rn'
alias mountedinfo='df -hT'

alias shortcuts='echo "=== Aliases in .bash_aliases ==="; grep -E "^alias|^#|^[[:space:]]*#" ~/.bash_aliases -B 1 | less'
