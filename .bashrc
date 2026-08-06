### PATH
# for npm i -g installs (and node) being available globally without doing any bs
# will be written to by .bashrc, which is why we export it
export NVM_BINPATH="$HOME/.nvmbin"

# -s checks if file has data
if [ -s "$NVM_BINPATH" ] ; then
	export PATH="$(cat "$NVM_BINPATH"):$PATH"
fi

mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/Binaries/bin"
export PATH="$HOME/Binaries/bin:$HOME/.local/bin:$PATH"



### Exports
export dt="$HOME/Desktop"
export dl="$HOME/Downloads"
export dc="$HOME/Documents"
export pc="$HOME/Pictures"
export vd="$HOME/Videos"
export as="$HOME/Assets"
export bn="$HOME/Binaries"
export so="$HOME/src"
export va="$HOME/Vault"
export nts="$HOME/Documents/notes"
export bin="$HOME/.local/bin"

export EDITOR=nvim
export SUDO_EDITOR="env XDG_CONFIG_HOME=$HOME/.config XDG_DATA_HOME=$HOME/.local/share XDG_STATE_HOME=$HOME/.local/state XDG_CACHE_HOME=$HOME/.cache nvim"
export TERMINAL="kitty"
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
export GPG_TTY=$(tty)

# man with nvim
export MANPAGER="sh -c 'nvim +Man!'"

# I alt+f4 out of windows so much so i'm writing every command
export PROMPT_COMMAND="history -a"



### Only continue if not running interactively
# undo lazy loading so login shells can get all the goodies
case $- in *i*) ;; *) return ;; esac



### Lazy loads
export NVM_DIR="$HOME/.nvm"

nvm () { __lazy_nvm nvm "$@"; }
node () { __lazy_nvm node "$@"; }
npm () { __lazy_nvm npm "$@"; }
npx () { __lazy_nvm npx "$@"; }

__lazy_nvm() {
	unset -f __lazy_nvm nvm node npm npx

	# load nvm
	[ -s "$NVM_DIR/nvm.sh" ] && builtin source "$NVM_DIR/nvm.sh"
	[ -s "$NVM_DIR/bash_completion" ] && builtin source "$NVM_DIR/bash_completion"

	# store the default nvm binpath so we can attach it to our $PATH in a non-interactive session
	# see .profile for implementation
	dirname $(nvm which default) > "$NVM_BINPATH"
	unset NVM_BINPATH

	# Instantly execute whatever command initiated the trigger block
	$@
}



### Shell options
# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000

# you can use ** in glob to recurse into directories
shopt -s globstar

# automatically updates window size
shopt -s checkwinsize
shopt -s histappend

# dollar signs for cd shortcuts
shopt -u cdable_vars

# case insensitive autocomplete
bind "set completion-ignore-case on"

# Colors
set_PS1() {
	local boldblack='\[\033[01;30m\]'
	local boldred='\[\033[01;31m\]'
	local boldgreen='\[\033[01;32m\]'
	local boldyellow='\[\033[01;33m\]'
	local boldblue='\[\033[01;34m\]'
	local boldmagenta='\[\033[01;35m\]'
	local boldcyan='\[\033[01;36m\]'
	local boldwhite='\[\033[01;37m\]'
	local reset='\[\033[00m\]'

	local username_color=$boldgreen
	local hostname_color=$boldcyan
	local directory_color=$boldblue
	local tail_color=$reset

	local color_prompt='yes'
	local prompt='$'

	local host1="superkingcraptop"
	local host2="plasma"

	local host=$(hostname)

	if [[ $host == $host1 ]] ; then
		unset host
	elif [[ $host == $host2 ]]; then
		unset host
		username_color=$boldwhite
		directory_color=$boldmagenta
	else
		prompt='='
	fi

	# Handle terminals that don't support color
	case "$TERM" in
		dumb) color_prompt='no';;
		mono) color_prompt='no';;
		vt100) color_prompt='no';;
	esac

	if [ "$color_prompt" == 'no' ]; then
		PS1="$\u${name:+ [$name]} \w $prompt "
		return
	fi

	PS1="${username_color}\u${hostname_color}${host:+ [$host]} ${directory_color}\w ${tail_color}${prompt} ${reset}"
}
set_PS1
unset set_PS1



### Keybinds
# Ctrl + Backspace: Delete one word backward
bind '"\C-h": backward-kill-word'

# Autocomplete (like zsh kinda not really)
bind 'TAB: complete'
bind '\C-y: menu-complete'
bind '"\C-e": menu-complete-backward'

# Shift + End (for use with keyd)
bind '"\e[1;2F": kill-whole-line'

# enable programmable completion features
if [ -f /usr/share/bash-completion/bash_completion ]; then
	source /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
	source /etc/bash_completion
fi



### Aliases and functions
alias mv='mv -i'
alias ls='ls --color=auto -AF'
alias la='command ls --color=auto -a'
alias l='command ls --color=auto'
alias ll='command ls -alFh'
alias cp='cp -r'
alias d='cd'
alias v='nvim'
alias quit='exit'
alias ':q'="exit"
alias tree="eza -AT --color=auto --icons=auto"
alias kssh='kitty +kitten ssh'
alias pse="ps -e -o pid,command"
alias rc="$EDITOR $HOME/.bashrc"

alias grep='grep --color=auto -i -P'
# Cool grep options:
## builtin source matches any character
## *: 0+, +; 1+ {a,b}: a-b
## o (nly match)
## n (include line numbers, follow with a | cut -d: -f1 to get them out)
## v (invert match)
## i(gnore case)
## P (use perl's backslash regex - \w(ord), not \W(ord), \s(pace), \< beginning of word, \> end of word)
##   character classes: [a-zA-Z] (or [a-z] with -i), you can match not with ^ at beginning ([^a-z])

cd() {
	builtin cd "$@" && ls
}

cdback() {
	local count=${1:-1}
	local path=""
	for ((i=0; i<count; i++)); do path="../$path"; done
	cd "$path"
}
alias '..'=cdback

# -R (allow color display, required to work with bat)
bat() {
	batcat --color=always "$@" | less -R
}

export CLIPBOARD="xclip -sel clipboard"
if [[ -n "$WSL_DISTRO_NAME" ]]; then
	CLIPBOARD='clip.exe'
fi

clip() {
	# prints to the terminal
	tee /dev/tty | eval $CLIPBOARD
	printf '\n^^^\nCopied to clipboard.\n'
}
alias copy="clip"

skconfig() {
	git --git-dir="$HOME"/.skconfig --work-tree="$HOME" "$@"
}
builtin source /usr/share/bash-completion/completions/git
__git_complete skconfig git



### External functions
bash_scripts_path="$HOME/.bash_scripts"
# checks if any scripts exist under this glob and if not returns an error code (which fails the if)
if compgen -G "$bash_scripts_path/*.bash" >/dev/null; then
	for script in "$bash_scripts_path"/*.bash; do
		builtin source "$script"
	done
else 
	echo "Hey where'd your scripts go"
fi

ilab-mount() {
	local clean="nop"
	local MOUNT_DIR="$HOME/Remote"

	fusermount3 -uz "$MOUNT_DIR"
	ssh -fN ilab

	rclone mount ilab-mount: $MOUNT_DIR \
		--vfs-cache-mode full \
		--no-modtime \
		--no-checksum \
		--vfs-write-back 0s \
		--vfs-cache-max-age 24h \
		--vfs-cache-max-size 32G \
		--dir-cache-time 1s \
		--attr-timeout 1s \
		--vfs-read-ahead 256M \
		--vfs-fast-fingerprint \
		--buffer-size 32M \
		"$@" &>/dev/null &
	local RCLONE_PID="$!"

	cleanup() {
		[[ $clean == "yep" ]] && return
		clean="yep"

		fusermount3 -uz "$MOUNT_DIR" 2>/dev/null
		kill "$RCLONE_PID" 2>/dev/null
		ssh -O exit ilab 2>/dev/null

		echo "$MOUNT_DIR"
	}

trap cleanup EXIT
ssh ilab
cleanup
}

# --- SAFEME ALIASES (START) ---
if [ -f /usr/local/bin/safe-rm ]; then
	alias rm='/usr/local/bin/safe-rm'
elif [ -f $HOME/.local/bin/safe-rm ]; then
	alias rm='$HOME/.local/bin/safe-rm'
fi

# Force bash to expand aliases after sudo otherwise it would bypass everything
alias sudo='sudo '
export SAFERM_confirmPhrases='eradicate them ; remove them ; send them away ; delete them ; confirm ; proceed'
export SAFERM_triggerCount=10

# Run a check if installed (useful for users who frequently pull down their configuration from github, etc)
# If safe-rm is installed, this will do absolutely nothing
amisafe -i
# --- SAFEME ALIASES (END) ---
