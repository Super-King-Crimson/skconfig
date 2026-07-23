#!/bin/bash
cd "$(dirname "$0")" || exit
ME=$(basename "$0")
LOGFILE="log.txt"

touch $LOGFILE
mv $LOGFILE "old.$LOGFILE"

echo $(date +"%m-%d-%Y @ %H:%M:%S") >> $LOGFILE

for file in ./*.sh; do
	if [[ -f "$file" && $(basename "$file") != "$ME" ]] ; then
		if [[ -x "$file" ]]; then
			echo "Starting $file" >> "$LOGFILE"
			nohup ./"$file" > /dev/null 2>&1 &
		else
			echo "ERROR: $file is not executable (chmod +x it!)" >> "$LOGFILE"
		fi
	fi
done

# Append some new lines to make it easier to read
printf "\n\n" >> $LOGFILE
cat "old.$LOGFILE" >> $LOGFILE
rm "old.$LOGFILE"
