if ! builtin command -v xdotool &>/dev/null; then
	# does xdotool exist
	# the only reason im making this function is so I have a reference on how to check if a process exists
	# echo xdotool not installed >&2
	return
fi

# :r !ls:  reads the output of the ls command and puts it below the cursor position.
__xdotool_completions() {
	local cur="${COMP_WORDS[COMP_CWORD]}"
	local options="getactivewindow getwindowfocus getwindowname getwindowpid getwindowgeometry getdisplaygeometry search selectwindow help version behave behave_screen_edge click getmouselocation key keydown keyup mousedown mousemove mousemove_relative mouseup set_window type windowactivate windowfocus windowkill windowclose windowmap windowminimize windowmove windowraise windowreparent windowsize windowunmap set_num_desktops get_num_desktops set_desktop get_desktop set_desktop_for_window get_desktop_for_window get_desktop_viewport set_desktop_viewport exec sleep"

	COMPREPLY=( $(compgen -W "$options" -- "$cur"))
}

complete -F __xdotool_completions xdotool
