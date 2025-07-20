#!/bin/sh

# Check if log file was passed and exists
LOG="$1"
[ -f "$LOG" ] || { echo "Usage: $0 log.csv"; exit 1; }

# Create a temporary folder to store job data per PID
TMPDIR=$(mktemp -d)
# Clean up temp files on exit
trap 'rm -rf "$TMPDIR"' EXIT

# Convert HH:MM:SS to total seconds (portable)
to_sec() {
  h=$(printf "%d" "$(echo "$1" | cut -d: -f1 | sed 's/^0*//')")
  m=$(printf "%d" "$(echo "$1" | cut -d: -f2 | sed 's/^0*//')")
  s=$(printf "%d" "$(echo "$1" | cut -d: -f3 | sed 's/^0*//')")
  echo $((h * 3600 + m * 60 + s))
}

# Read each line of the CSV
while IFS=, read -r time desc action pid; do
  # Clean and normalize fields
  time=$(printf "%s" "$time" | tr -d ' ')
  action=$(printf "%s" "$action" | tr -d '[:space:]')
  desc=$(printf "%s" "$desc" | xargs)  # trim leading/trailing spaces

  # Convert action to uppercase safely
  case "$action" in
    start|START) action=START ;;
    end|END) action=END ;;
    *) action=$(printf "%s" "$action" | tr 'a-z' 'A-Z') ;;
  esac

  if [ "$action" = "START" ]; then
    echo "$time|$desc" > "$TMPDIR/$pid"

  elif [ "$action" = "END" ] && [ -f "$TMPDIR/$pid" ]; then
    IFS="|" read st desc < "$TMPDIR/$pid"
    start_sec=$(to_sec "$st")
    end_sec=$(to_sec "$time")
    dur=$((end_sec - start_sec))

    # Only report if job took longer than 5 minutes
    if [ "$dur" -gt 600 ]; then
      level="ERROR"
    elif [ "$dur" -gt 300 ]; then
      level="WARNING"
    else
      rm -f "$TMPDIR/$pid"
      continue
    fi

    hr=$((dur / 3600))
    min=$(( (dur % 3600) / 60 ))
    sec=$((dur % 60))

    printf "[%s] PID %s (%s) took %02d:%02d:%02d\n" \
      "$level" "$pid" "$desc" "$hr" "$min" "$sec"

    rm -f "$TMPDIR/$pid"
  fi
done < "$LOG"
