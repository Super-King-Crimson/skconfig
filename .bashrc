# ~/.bashrc

# If not running interactively, don't do anything
case $- in
    *i*) ;;
    *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend


HISTSIZE=1000
HISTFILESIZE=2000

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
# Adjusted for EndeavourOS/Arch: Checks for a custom variable
# since /etc/debian_chroot won't exist.
if [ -z "${debian_chroot:-}" ]; then
    if [ -r /etc/debian_chroot ]; then
        debian_chroot=$(cat /etc/debian_chroot)
    elif [ -n "${CHROOT_NAME:-}" ]; then
        debian_chroot="$CHROOT_NAME"
    fi
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt

force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi


if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u \[\033[00m\]\[\033[01;34m\]\w \[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u \w \$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
    xterm*|rxvt*)
        PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
        ;;
    *)
        ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi


# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi




### Set defaults
export EDITOR="nvim"
export TERMINAL="konsole"
export VISUAL="$EDITOR"


### Shortcuts
export dt=$HOME/Desktop
export dl=$HOME/Downloads
export dc=$HOME/Documents
export pc=$HOME/Pictures
export vd=$HOME/Videos
export as=$HOME/Assets
export bn=$HOME/Binaries
export so="$HOME/src"
export im="$HOME/IMPORTANT/"
export nts="$HOME/Desktop/notes"
export bin="$HOME/.local/bin"
export prj="$HOME/Documents/Projects"
export tch="$HOME/src/scratch"




# Shell configuration
shopt -u cdable_vars
shopt -s direxpand

### Simple aliases
alias ll='ls -alFh'
alias la='ls -A'
alias d='cd'
alias v='nvim'
alias trash='trash-put'
alias restore='trash-restore'
alias glow='glow -p'

# other useful flags:
#   tree: I ignore-pat, L depth, i (no indent lines), f(ull relative path) 


### Less simple aliases
# literally just a filter (-o allows mapping to output)
# ps -e is equal to ps aux btw (list all processes: you probably want to run this thru grep -E)
alias pse="ps -e -o pid,command"

# don't ask me why this works... creates a file with specified octal permission code
alias ptouch="install /dev/null -m"

# useful flags: o (nly match), n (line numbers), E (use extended regex), v (invert match)
alias grep='grep --color=auto -E'

# -R (allow color display, required to work with bat)
bat() {
    batcat --color=always "$@" | less -R
}

# double reverses a string so you can cut from the end
# bro == echo ok bro | rcut -c-3
rcut() {
    rev | cut "$@" | rev
}

# Copies output of last command to clipboard
# Change this on wayland lol
clip() {
    tr -d '\n' | xclip -selection clipboard
    echo Copied to clipboard.
}
alias copy="clip"




### Scripts
__bridge="/tmp/.uid${UID}_${USER}.x"
x() {
    local output
    output=$(xargs "$@")

    echo "$output" > "$__bridge"
    echo "$output"
}

xd() {
    x dirname
}

xc() {
    if [ ! -s "$__bridge" ]; then
        echo Failed to read from bridge.
        return 1
    fi

    local target
    target=$(head "$__bridge")
    builtin cd "$target" && ls
}

xcd() {
    which "$@" | xd && xc
}

xcr() {
    realpath "$@" | xd && xc
}

# Encrypt a folder into a symmetrical GPG archive
encrypt_archive_symmetrical_gpg() {
    local GPG_OPTS=""
    local OPTIND=1  # Reset getopts index for function calls

    # Parse flags
    while getopts "f" opt; do
        case "$opt" in
            f) GPG_OPTS="--no-symkey-cache" ;;
            *) echo "Usage: enc-sym [-f] <folder_path>"; return 1 ;;
        esac
    done

    shift $((OPTIND-1)) # Remove the flags from the argument list

    local folder_path="$1"
    local output_name=$(basename "$folder_path")
    if [[ -z "$folder_path" ]]; then
        echo "Usage: enc-sym [-f] <folder_path>"
        return 1
    fi

    # -c uses symmetric encryption
    # --pbkdf2 specifies the password-based key derivation function
    tar -cf - "$folder_path" | gpg $GPG_OPTS -c -o "$output_name.tar.gpg"

    local status_tar=${PIPESTATUS[0]}
    local status_gpg=${PIPESTATUS[1]}
    if [[ $status_tar -eq 0 && $status_gpg -eq 0 ]]; then
        echo "Archive encrypted successfully as $output_name.tar.gpg."
        echo "Please delete the original directory."
    fi
}
alias enc='encrypt_archive_symmetrical_gpg'

# Decrypt and extract a symmetrical GPG archive
decrypt_extract_symmetrical_gpg() {
    local GPG_OPTS=""
    local OPTIND=1

    # Parse flags
    while getopts "f" opt; do
        case "$opt" in
            f) GPG_OPTS="--no-symkey-cache" ;;
            *) echo "Usage: dec-sym [-f] <encrypted_data_path>"; return 1 ;;
        esac
    done
    shift $((OPTIND-1))

    local encrypted_data_path="$1"
    if [[ -z "encrypted_data_path" ]]; then
        echo "Usage: dec-sym [-f] <encrypted_data_path>"
        return 1
    fi

    # -d decrypts the file and pipes the stdout directly to tar
    gpg $GPG_OPTS -d "$encrypted_data_path" | tar -xf -

    local status_gpg=${PIPESTATUS[0]}
    local status_tar=${PIPESTATUS[1]}
    if [[ $status_gpg -eq 0 && $status_tar -eq 0 ]]; then
        echo "Archive decrypted and extracted to current directory."
        echo "Remember to re-encrypt this file after you are done."
    fi
}
alias dec='decrypt_extract_symmetrical_gpg'



# PATH modification
export PATH="$HOME/.local/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
. "$HOME/.cargo/env"
