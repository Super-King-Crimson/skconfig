#!/usr/bin/env bash

PORT="$1"

if [ -z "$FILEPATH" ]; then
	FILEPATH="$HOME/Public"
fi

if [ -z "$PORT" ]; then
	PORT=80
fi

echo "FILEPATH: $FILEPATH"
python3 -m http.server "$PORT" -d "$FILEPATH"
