# Contributing

> See [CLAUDE.md](./CLAUDE.md) for coding conventions and style guidelines.

## Requirements

- A POSIX-compliant `sh` shell (no bash or zsh features)
- `make`
- [ShellCheck](https://www.shellcheck.net/) — vendored at `vendor/shellcheck`, or install your own

No other dependencies are needed. The test framework and argument parser are vendored.

## Project Structure

```
semver-tool-posix/
├── src/
│   ├── semver              # Main entry point and CLI dispatch
│   ├── semver_validate.sh  # Version string validation and parsing
│   ├── semver_get.sh       # "get" subcommand — extract version parts
│   ├── semver_compare.sh   # "compare" subcommand — compare two versions
│   ├── semver_diff.sh      # "diff" subcommand — find most significant difference
│   └── semver_bump.sh      # "bump" subcommand — increment version components
├── spec/
│   ├── spec_helper.sh      # ShellSpec test helper (loaded by all specs)
│   ├── general_spec.sh     # Tests for --help, --version, and error handling
│   ├── validate_spec.sh    # Tests for the validate subcommand
│   ├── get_spec.sh         # Tests for the get subcommand
│   ├── compare_spec.sh     # Tests for the compare subcommand
│   ├── diff_spec.sh        # Tests for the diff subcommand
│   └── bump_spec.sh        # Tests for the bump subcommand
├── bin/
│   ├── semver              # Built artifact — single bundled script (git-ignored)
│   ├── build.sh            # Build script — bundles src/ into bin/semver, stamps VERSION
│   └── install.sh          # Curl-pipe installer for end users
├── vendor/
│   ├── getoptions.sh       # Argument parser library (do not modify)
│   ├── shellcheck          # ShellCheck binary (do not modify)
│   └── shellspec-0.28.1/   # ShellSpec test framework (do not modify)
├── reference/
│   ├── getoptions.md       # getoptions API reference
│   └── shellspec.md        # ShellSpec testing reference
├── VERSION                 # Single source of truth for the version string
├── Makefile                # test, check, build, install targets
├── .shellspec              # ShellSpec configuration
└── LICENSE                 # Apache License 2.0
```

### Source modules (`src/`)

Each `src/semver_*.sh` file is a self-contained module sourced by `src/semver`. To avoid conflicts
with POSIX `local` (which is not standard), each module uses a unique variable prefix:

| Module               | Prefix |
| -------------------- | ------ |
| `semver_validate.sh` | `_sv_` |
| `semver_get.sh`      | `_sg_` |
| `semver_compare.sh`  | `_sc_` |
| `semver_diff.sh`     | `_sd_` |
| `semver_bump.sh`     | `_sb_` |

Shared output variables set by validation/parsing: `_V_MAJOR`, `_V_MINOR`, `_V_PATCH`, `_V_PREREL`,
`_V_BUILD`.

### Build (`bin/build.sh`)

The build script bundles `src/semver` and all its sourced modules into a single self-contained file
at `bin/semver`. It inlines:

- All `. "$SCRIPT_DIR/semver_*.sh"` source lines
- The `getoptions` eval with its generated output
- The version string from the root `VERSION` file (stamped as a literal)

### Vendored dependencies (`vendor/`)

These are checked in and should not be modified:

- **getoptions.sh** — POSIX argument parser
- **shellcheck** — Static analysis tool for shell scripts
- **shellspec-0.28.1/** — BDD-style test framework

## Shell Conventions

All scripts must be POSIX-compliant `sh`. This means:

- No `local` keyword — use prefixed variable names (see table above)
- No `[[ ]]` — use `[ ]` or `case` statements
- No `echo -e` — use `printf '%s\n'`
- No `=~` regex — use `grep -Eq` or `expr`
- No arrays, no process substitution

Additional rules:

- `set -eu` at the top of every script
- Exit 0 on success, non-zero on failure
- `--help` must work even when required arguments are missing
- Resolve script directory with: `SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"`

## Make Targets

| Target              | Description                                                      |
| ------------------- | ---------------------------------------------------------------- |
| `make test`         | Run the ShellSpec test suite                                     |
| `make check`        | ShellCheck the `src/` directory                                  |
| `make check-test`   | ShellCheck the `spec/` directory                                 |
| `make check-vendor` | ShellCheck the `vendor/` directory                               |
| `make build`        | Check, test, bundle into `bin/semver`, and ShellCheck the output |
| `make install`      | Build then install to `$PREFIX/bin` (default: `/usr/local`)      |

## Testing

Tests use [ShellSpec](https://shellspec.info/) vendored at `vendor/shellspec-0.28.1/shellspec`.
Test files live in `spec/` with a `_spec.sh` suffix.

```sh
make test
```

Conventions:

- Use `When run command sh ./src/semver ...` (not `./src/semver` directly — subshells don't
  preserve execute permissions reliably)
- Tests that expect failure should include `The stderr should be present` to avoid ShellSpec
  warnings
- See `reference/shellspec.md` for the full DSL reference

## Workflow

1. Edit source files in `src/`
2. Write or update tests in `spec/`
3. Run `make check` and `make check-test` to verify POSIX compliance
4. Run `make test` to verify
5. Run `make build` to produce and validate the bundled script

## Release

The `main` branch is always the latest release. All changes must go through a pull request:

1. Create a feature branch from `main`
2. Update the `VERSION` file if releasing a new version
3. Make your changes and verify with `make build`
4. Open a PR targeting `main`
5. Once approved and merged, `main` is the new release
