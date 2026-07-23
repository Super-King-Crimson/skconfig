# Encrypt a folder into a symmetrical GPG archive
encrypt_archive_symmetrical_gpg() {
	local GPG_OPTS=""
	local OPTIND=1  # Reset getopts index for function calls

	# Parse flags
	while getopts "f" opt; do
		case "$opt" in
			f) GPG_OPTS="--no-symkey-cache" ;;
			*) echo "Usage: enc [-f] <folder_path>"; return 1 ;;
		esac
	done

	# Remove the flags from the argument list
	shift $((OPTIND-1))

	local folder_path="$1"
	local output_name=$(basename "$folder_path")
	if [[ -z "$folder_path" ]]; then
		echo "Usage: enc [-f] <folder_path>"
		return 1
	fi

	# -c uses symmetric encryption
	tar -cf - "$folder_path" | gpg $GPG_OPTS -c -o "$output_name.tar.gpg"

	local status_tar=${PIPESTATUS[0]}
	local status_gpg=${PIPESTATUS[1]}
	if [[ $status_tar -eq 0 && $status_gpg -eq 0 ]]; then
		echo "Archive encrypted successfully as $output_name.tar.gpg."
		echo "Please delete the original directory."
	fi
}

alias enc='encrypt_archive_symmetrical_gpg'
