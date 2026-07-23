# Decrypt and extract a symmetrical GPG archive
decrypt_extract_symmetrical_gpg() {
	local GPG_OPTS=""
	local OPTIND=1

	# Parse flags
	while getopts "f" opt; do
		case "$opt" in
			f) GPG_OPTS="--no-symkey-cache" ;;
			*) echo "Usage: dec [-f] <encrypted_data_path>"; return 1 ;;
		esac
	done
	shift $((OPTIND-1))

	local encrypted_data_path="$1"
	if [[ -z "$encrypted_data_path" ]]; then
		echo "Usage: dec [-f] <encrypted_data_path>"
		return 1
	fi
	
	(
		# Run in subshell so we can set pipefail without affecting main script
		# set -e: exit if any command has nonzero error code
		# set -o pipefail: command with pipes returns first nonzero error code, not just error code of last command
		set -eo pipefail
		# -d decrypts the file and pipes the stdout directly to tar
		gpg $GPG_OPTS -d "$encrypted_data_path" | tar -xf -
	)

	if [ $? -eq 0 ]; then
		echo Archive decrypted and extracted to current directory.
		echo Remember to re-encrypt this file after you are done.
	else
		echo Decryption failed.
	fi
}

alias dec='decrypt_extract_symmetrical_gpg'
