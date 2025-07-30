
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

# Alerts & Other Aliases
###############################################################################
alias alert='notify‑send …'
alias openports='netstat -nape --inet'   # show open TCP/UDP ports

# Aliases to show disk space and space used in a folder
alias diskspace="du -S | sort -n -r |more"
alias folders='du -h --max-depth=1'
alias folderssort='find . -maxdepth 1 -type d -print0 | xargs -0 du -sk | sort -rn'
alias mountedinfo='df -hT'

# Alias to show basic aliases
alias shortcuts='echo "=== Aliases in .bash_aliases ==="; grep -E "^alias|^#|^[[:space:]]*#" ~/.bash_aliases -B 1 | less'

# Tmux Help Alias
alias tmuxhelp='printf "%s\n" \
"=== Basic tmux Commands ===" \
"" \
"# Session Management" \
"tmux or tmux new.................Start a new tmux session" \
"tmux attach or tmux a............Attach to an existing session" \
"tmux list-sessions or tmux ls....List all tmux sessions" \
"C-a d............................Detach from the current session" \
"" \
"# Window Management" \
"C-a c......................Create a new window" \
"C-a n......................Switch to the next window" \
"C-a p......................Switch to the previous window" \
"C-a 0-9....................Switch to a window by number (0-9)" \
"C-a ,......................Rename the current window" \
"C-a &......................Close the current window" \
"" \
"# Pane Management" \
"C-a %......................Split pane vertically" \
"C-a \"......................Split pane horizontally" \
"C-a o......................Switch to the next pane" \
"C-a arrow keys.............Navigate between panes (up, down, left, right)" \
"C-a x......................Close the current pane" \
"" \
"# Miscellaneous" \
"C-a ?......................Show tmux key bindings" \
"C-a :......................Enter command mode (e.g., :source-file ~/.tmux.conf)" \
"" \
"Note: C-a represents your custom tmux prefix (Ctrl-a)." | less'
