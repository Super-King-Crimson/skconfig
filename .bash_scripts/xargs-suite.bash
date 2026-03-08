### Scripts
__bridge="/tmp/.uid${UID}_${USER}.x"

# usage: pipe arguments to functions, and this will write the output to a file that can be read
# main use case is allowing you to pipe arguments to scripts that don't accept them
x() {
	local output
	output=$(xargs "$@")

	# tee didn't work for some reason so ig we're doing this
	echo "$output" > "$__bridge"
	echo "$output"
}

xd() {
	x dirname
}

xp() {
	x realpath
}

# Everyime x is called, it writes its output to $__bridge
# If you want to cd to that directory,
# you can't simply pipe to it like .. | x cd (for linux reasons)
# So made this function xc(d) that reads that output and attempts to cd to it
xc() {
	if [ ! -s "$__bridge" ]; then
		echo Failed to read from bridge.
		return 1
	fi

	local target
	target=$(head "$__bridge")
	builtin cd "$target" && ls
}
