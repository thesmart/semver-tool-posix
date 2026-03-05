# Agent Instructions for `./gate`

Consult the [README.md](./README.md) specification.

## Shell Conventions

Shell scripts should be POSIX compliant executable `sh` (not `bash` or `zsh`):

- ALWAYS be idempotent (safe to run multiple times, same result)
- ALWAYS check `--help` options first, so that it works even if there are required flags
- ALWAYS exit with code 0 on success, non-zero on failure
- ALWAYS use [getoptions](./reference/getoptions.md) for parameter parsing
- ALWAYS use [shellspec](./reference/shellspec.md) for testing
- ALWAYS resolve the directory this script lives for sourcing other scripts:
  `SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"`
- NEVER modify files unless explicitly intended
- Provide clear error messages
- Assume relative path parameters are relative to CWD
- Validate all file/dir path parameters for safety
- Set `+x` option on executable scripts

### Positional Parameters

- Positional parameters are arguments provided without flags.
- They are interpreted based on their ORDER in the command line.
- Required arguments come first, optional ones last.
- Example: `git commit -m "message" file1.txt file2.txt` (files are positional)
