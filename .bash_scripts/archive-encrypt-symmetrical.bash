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

	(
		# Run in subshell so we can set pipefail without affecting main script
		# set -e: exit if any command has nonzero error code
		# set -o pipefail: command with pipes returns first nonzero error code, not just error code of last command
		set -eo pipefail
		# -d decrypts the file and pipes the stdout directly to tar
		tar -cf - "$folder_path" | gpg $GPG_OPTS -c -o "$output_name.tar.gpg"
	)

	if [ $? -eq 0 ]; then
		echo Archive encrypted successfully as $output_name.tar.gpg.
		echo Please delete the original directory.
	else
		echo Failed to encrypt $(realpath folder_path).
	fi
}

alias enc='encrypt_archive_symmetrical_gpg'
