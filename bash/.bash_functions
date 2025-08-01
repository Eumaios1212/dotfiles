
# ~/.bash_functions ─ personal helper library
# This file is sourced from ~/.bashrc (see dot‑files repo).
# Only reusable functions & their helper aliases live here –
# no exports, PATH mangling, or prompt definitions.
# ---------------------------------------------------------------------------

# Function for updates, since sudo is needed for apt, should not be used with pipx:
update() {
    # --- OS packages ---
    sudo apt update           # refresh package lists
    sudo apt upgrade -y       # upgrade packages
    sudo apt autoremove -y    # clean leftovers

    # --- pipx packages ---
    pipx upgrade-all --include-injected
}

# Pretty, colourised `history` output with timestamps and Git‑line highlight.
h() {
  local RESET=$'\e[0m'        # reset / normal
  local YEL=$'\e[1;33m'       # bright yellow
  local CYA=$'\e[1;36m'       # bright cyan

  history | awk -v y="$YEL" -v c="$CYA" -v r="$RESET" '
  {
      num = $1
      if ($2 ~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/ && $3 ~ /^[0-9]{2}:[0-9]{2}:[0-9]{2}$/) {
          ts  = $2 " " $3
          cmd_start = index($0,$4)
      } else {
          ts  = ""
          cmd_start = index($0,$2)
      }
      cmd = substr($0, cmd_start)
      colour = (cmd ~ /^git/) ? c : y
      printf "%s%5s%s  %s%s%s  %s\n", colour, num, r, (ts ? c ts r "  " : ""), "", "", cmd
  }'
}

# Extract nearly any archive format with:  extract <file> [...]
extract() {
  for archive in "$@"; do
    if [[ -f $archive ]]; then
      case $archive in
        *.tar.bz2|*.tbz2) tar xvjf "$archive" ;;
        *.tar.gz|*.tgz )  tar xvzf "$archive" ;;
        *.tar)           tar xvf  "$archive" ;;
        *.bz2)           bunzip2  "$archive" ;;
        *.gz)            gunzip   "$archive" ;;
        *.rar)           rar x    "$archive" ;;
        *.zip)           unzip    "$archive" ;;
        *.Z)             uncompress "$archive" ;;
        *.7z)            7z x     "$archive" ;;
        *) echo "extract: cannot handle '$archive'" ;;
      esac
    else
      echo "extract: '$archive' is not a file" >&2
    fi
  done
}

# ftext <pattern> – colour‑grep recursively in current dir and page via less.
ftext() {
  grep -iIHrn --color=always "$1" . | less -R
}

# cpp SRC DST  – copy with ASCII progress bar.
cpp() {
  set -e
  strace -q -ewrite cp -- "$1" "$2" 2>&1 | awk -v total_size="$(stat -c '%s' "$1")" '
    { count += $NF }
    (count % 10 == 0) {
      percent = count / total_size * 100
      printf "\r%3d%% [", percent
      printf ">"
      for (i=percent;i<100;i++) printf " "
      printf "]"
    }
    END { print "" }'
}

# whatismyip – internal & external IP display.
whatsmyip() {
  echo -n "Internal IP: "
  if command -v ip &>/dev/null; then
    ip -o -4 addr show scope global | awk '{print $4}' | cut -d/ -f1 | head -n1
  else
    ifconfig | awk '/inet (addr:)?/ && $2 != "127.0.0.1" {print $2; exit}'
  fi
  echo -n "External IP: "
  curl -s --max-time 3 https://ifconfig.me || curl -s https://icanhazip.com
  echo
}
alias whatismyip=whatsmyip

# Quick add‑commit (gcom "msg") and add‑commit‑push (lazyg "msg").
gcom()  { git add . && git commit -m "$1"; }
lazyg() { git add . && git commit -m "$1" && git push; }
