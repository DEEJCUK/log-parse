# log-parse

A simple Python and shell script toolkit to parse log files in CSV format and report long-running processes by PID.

## Usage

### Python
```
python log_parse.py log.csv
```

### Shell
```
./log_parse.sh log.csv
```

- Input file must be a CSV with 4 columns: `time`, `description`, `action`, `pid`.
- Reports WARNING for durations >5 minutes, ERROR for durations >10 minutes.
- Output is printed to the console.

## Example log format
```
11:35:23,scheduled task 032, START,37980
11:35:56,scheduled task 032, END,37980
```

## Requirements
- Python 3.x for the Python script
- POSIX shell (sh, bash, zsh) for the shell script

For the shell script, make sure it is executable:
```
chmod +x log_parse.sh
```

No dependencies beyond the Python standard library or standard shell utilities.

## Example output
```
[WARNING] PID 37980 (scheduled task 032) took 00:05:33
[ERROR] PID 10515 (scheduled task 386) took 00:10:10
```

## Which script to use?

- **Python script**: Recommended for portability, readability, and handling larger or more complex log files. Use if you want clearer error messages or plan to extend functionality.
- **Shell script**: Useful for quick checks, automation in shell environments, or when Python is not available (eg: in a minimal or locked down environment). Best for small logs or integration into shell pipelines, If the log file is very large, the script may create many files in tmp, which could be a resource concern.
- **Considerations**: 
The use of $TMPDIR/$pid for temporary files is safe as long as PIDs are not attacker-controlled. If the log file is untrusted, consider sanitizing $pid to avoid path traversal (e.g., remove slashes or dots).
If you expect untrusted log files, add validation for $pid to ensure it contains only safe characters (e.g., digits).