# double reverses a string so you can cut from the end
# bro == echo ok bro | rcut -c-3
cutrev() {
	rev | cut "$@" | rev
}

# by default just gets the first line
cutlines() {
	if [[ $# -eq 0 ]]; then
		cut -d$'\n' -f1
	else
		cut -d$'\n' -f"$1"
	fi
}
