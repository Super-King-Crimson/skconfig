# Decrypt and extract a symmetrical GPG archive
decrypt_extract_symmetrical() {
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
	if [[ -z "encrypted_data_path" ]]; then
		echo "Usage: dec [-f] <encrypted_data_path>"
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
