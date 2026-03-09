### Directory shortcuts and settings
export dt="$HOME/Desktop"
export dl="$HOME/Downloads"
export dc="$HOME/Documents"
export pc="$HOME/Pictures"
export vd="$HOME/Videos"
export as="$HOME/Assets"
export bn="$HOME/Binaries"
export so="$HOME/src"
export im="$HOME/IMPORTANT/"
export nts="$HOME/Documents/notes"
export bin="$HOME/.local/bin"

export EDITOR="$HOME/.local/bin/nvim"
export SUDO_EDITOR="$EDITOR"
export TERMINAL="kitty"

# for use with nvim (idk why you have to wrap it in a shell but hey it works now)
export MANPAGER="sh -c 'nvim +Man!'"

# file where marks will be saved for Man files
export man_shada=$HOME/.manshada

### always have vi be system implementation of vi
unalias vi 2>/dev/null


# If not running interactively, don't do anything else
case $- in *i*) ;; *) return;; esac


export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# I alt+f4 out of windows so much so i'm writing every command
export PROMPT_COMMAND="history -a"

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
shopt -u cdable_vars

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ]; then
	if [ -r /etc/debian_chroot ]; then
		debian_chroot=$(cat /etc/debian_chroot)
	elif [ -n "${CHROOT_NAME:-}" ]; then
		debian_chroot="$CHROOT_NAME"
	fi
fi

# Handle terminals that don't support color
# add your terminal here
color_prompt='no'
case "$TERM" in
	*[si]tty*) color_prompt='yes';;
	*konsole*) color_prompt='yes';;
	*gnome*) color_prompt='yes';;
	*color*) color_prompt='yes';;
	linux) color_prompt='yes';;
esac

if [ "$color_prompt" = 'yes' ]; then
	PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u \[\033[00m\]\[\033[01;34m\]\w \[\033[00m\]\$ '
else
	PS1='${debian_chroot:+($debian_chroot)}\u \w \$ '
fi
unset color_prompt

# enable programmable completion features
if [ -f /usr/share/bash-completion/bash_completion ]; then
	source /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
	source /etc/bash_completion
fi







### Keybinds
# Ctrl + Backspace: Delete one word backward
bind '"\C-h": backward-kill-word'

# End + Delete: Delete whole line
bind '"\e[1;2F": kill-line'







### Aliases and functions
alias ls='ls --color=auto -AF'
# a ls-tee: prints original list while piping output
alias la='command ls --color=auto -a'
alias l='command ls --color=auto'
alias ll='command ls -alFh'
alias cp='cp -r'
alias d='cd'
alias v='nvim '
alias quit='exit'

# the vim pill has been devoured
alias ':q'="exit"

# ps -e == ps aux btw (use w/grep to find evil processes)
alias pse="ps -e -o pid,command"

# . matches any character
# *: 0+, +; 1+ {a,b}: a-b
# o (nly match)
# n (include line numbers, follow with a | cut -d: -f1 to get them out)
# v (invert match)
# i(gnore case)
# P (use perl's backslash regex - \w(ord), not \W(ord), \s(pace), \< beginning of word, \> end of word)
#	character classes: [a-zA-Z] (or [a-z] with -i), you can match not with ^ at beginning ([^a-z])
alias grep='grep --color=auto -i -P'



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

clip() {
	# prints to the terminal
	tee /dev/tty | xclip -selection clipboard
	printf '\nCopied to clipboard.\n'
}
alias copy="clip"


# PATH modification
export PATH="$HOME/.local/bin:$PATH"
export NVM_DIR="$HOME/.nvm"




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


### Lazy loads
skconfig() {
	[[ -z "$_lazy_git" ]] && __lazy_git
	git --git-dir="$HOME"/.skconfig --work-tree="$HOME" "$@"
}
complete -F __lazy_git skconfig

nvm () { __lazy_nvm "$@" && command nvm "$@"; }
node () { __lazy_nvm "$@" && command node "$@"; }
npm () { __lazy_nvm "$@" && command npm "$@"; }
npx () { __lazy_nvm "$@" && command npx "$@"; }
complete -F __lazy_nvm nvm
complete -F __lazy_nvm node
complete -F __lazy_nvm npm
complete -F __lazy_nvm npx


__lazy_git() {
	# associated variable with one
	# so you can do ! -z _lazy_git or whatever
	unset -f __lazy_git
	_lazy_git="yup"

	builtin source /usr/share/bash-completion/completions/git
	__git_complete skconfig git
}

__lazy_nvm() {
	unset -f __lazy_nvm
	unset -f nvm node npm npx

	complete -r nvm
	complete -r node
	complete -r npm
	complete -r npx

	[ -s "$NVM_DIR/nvm.sh" ] && builtin source "$NVM_DIR/nvm.sh"
	[ -s "$NVM_DIR/bash_completion" ] && builtin source "$NVM_DIR/bash_completion"
}



# useful info:
## exec >&- 2>&- closes stdout and stderr for the remainder of the script's execution

# useful cli arguments:
## tree: prints directory recursive, opts: I ignore-pat, L depth, i (no indent lines), f(ull relative path)



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
