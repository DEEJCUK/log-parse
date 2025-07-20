import sys

# Convert HH:MM:SS string to total seconds
def to_sec(t):
    h, m, s = map(int, t.strip().split(':'))
    return h * 3600 + m * 60 + s

# Check for correct usage
if len(sys.argv) != 2:
    print("Usage: python log_parse.py log.csv")
    sys.exit(1)

log = sys.argv[1]  # Get log file path from command line
starts = {}        # Dictionary to store start time and description for each PID

# Open and process the log file line by line
with open(log) as f:
    for line in f:
        # Split CSV line into fields and strip whitespace
        parts = [p.strip() for p in line.strip().split(',')]
        if len(parts) != 4:
            continue  # Skip lines that don't have exactly 4 fields
        time, desc, action, pid = parts
        action = action.upper()  # Normalize action to uppercase

        if action == "START":
            # Store start time and description for this PID
            starts[pid] = (time, desc)
        elif action == "END" and pid in starts:
            # If END and PID exists, calculate duration
            st, desc = starts.pop(pid)
            dur = to_sec(time) - to_sec(st)
            # Only log if duration > 5 minutes
            if dur > 600:
                level = "ERROR"
            elif dur > 300:
                level = "WARNING"
            else:
                continue  # Skip anything ≤ 5 minutes
            # Print formatted output
            print(f"[{level}] PID {pid} ({desc}) took {dur//3600:02}:{(dur%3600)//60:02}:{dur%60:02}")