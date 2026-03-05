# ShellSpec Reference (v0.28.1)

BDD unit testing framework for POSIX shells. Vendored at `vendor/shellspec-0.28.1/shellspec`.

## Quick Start

```sh
# Initialize project (creates .shellspec + spec/spec_helper.sh)
vendor/shellspec-0.28.1/shellspec --init

# Run all tests
vendor/shellspec-0.28.1/shellspec

# Run specific file or line
vendor/shellspec-0.28.1/shellspec spec/unit_spec.sh
vendor/shellspec-0.28.1/shellspec spec/unit_spec.sh:15:25
```

Tip: create a symlink or wrapper script for convenience. The agent should always use the newest
version in `vendor/`.

## Project Structure

```
.shellspec                  # Project options (required, marks project root)
spec/
  spec_helper.sh            # Global test config
  support/                  # Custom matchers, helpers
  *_spec.sh                 # Spec files (naming convention)
```

### .shellspec (options file)

One option per line, same as CLI flags:

```
--require spec_helper
--shell sh
```

### spec_helper.sh

```sh
set -eu

spec_helper_precheck() {
  minimum_version "0.28.0"
}

spec_helper_configure() {
  import 'support/custom_matcher'
}
```

Callbacks: `spec_helper_precheck`, `spec_helper_loaded`, `spec_helper_configure`.

## Spec File Anatomy

```sh
Describe 'my_function'
  Include ./src/my_script.sh    # Source the code under test

  It 'returns success'
    When call my_function "arg1"
    The output should eq "expected"
    The status should be success
  End
End
```

### Group Keywords

- `Describe` / `Context` - Example groups (nestable)
- `It` / `Example` / `Specify` - Individual test cases
- `End` - Closes any block

### Focused / Skipped / Pending

- `fDescribe`, `fIt` - Focus (run only these with `--focus`)
- `xDescribe`, `xIt` - Skip
- `Todo 'not yet implemented'` - Pending placeholder
- `Skip "reason"` / `Skip if 'desc' [ condition ]` - Conditional skip

## Evaluation (When)

```sh
When call function_name args...     # Run in current shell (can modify vars)
When run command cmd args...        # Run in subshell (can trap exits)
When run source ./script.sh         # Source script in subshell
```

- `call` - Use for functions; can only call once per test; must precede assertions.
- `run` - Use for commands/scripts that may `exit`; runs in subshell.

## Subjects

| Subject                          | Description                               |
| -------------------------------- | ----------------------------------------- |
| `stdout` / `output`              | Standard output                           |
| `stderr` / `error`               | Standard error                            |
| `status`                         | Exit code                                 |
| `variable VAR`                   | Shell variable (by name, no `$`)          |
| `value "$VAR"`                   | Evaluated expression                      |
| `path "file"` / `file` / `dir`   | Filesystem path                           |
| `entire output` / `entire error` | Full output (preserves trailing newlines) |

## Modifiers

Chain with `of` to extract parts of subjects:

```sh
The line 2 of output should eq "second line"
The lines of output should eq 5
The word 3 of output should eq "third"
The length of output should eq 42
The contents of file "path" should include "text"
The first line of stderr should start with "Error"
The word 2 of line 3 of output should eq "foo"
```

## Matchers

### String/Value

| Matcher                    | Description        |
| -------------------------- | ------------------ |
| `eq "str"` / `equal "str"` | Exact equality     |
| `start with "prefix"`      | Starts with        |
| `end with "suffix"`        | Ends with          |
| `include "substr"`         | Contains substring |
| `match pattern "glob*"`    | Glob pattern match |

### Status

| Matcher      | Description        |
| ------------ | ------------------ |
| `be success` | Exit code 0        |
| `be failure` | Exit code non-zero |
| `eq 127`     | Specific exit code |

### Variable State

| Matcher        | Description       |
| -------------- | ----------------- |
| `be defined`   | Variable is set   |
| `be undefined` | Variable is unset |
| `be present`   | Non-empty         |
| `be blank`     | Empty or unset    |
| `be exported`  | Exported variable |

### Filesystem

| Matcher                                         | Description    |
| ----------------------------------------------- | -------------- |
| `be exist`                                      | Path exists    |
| `be file` / `be directory`                      | Type check     |
| `be empty`                                      | Empty file/dir |
| `be symlink`                                    | Symlink        |
| `be readable` / `be writable` / `be executable` | Permissions    |

### Negation

```sh
The output should not eq "wrong"
The status should not be failure
```

## Hooks

```sh
Before 'setup_function'
After 'cleanup_function'
BeforeRun 'pre_run_hook'      # For `run` evaluation only
AfterRun 'post_run_hook'
```

Hooks run per-example (no BeforeAll/AfterAll).

## Data Helper (stdin)

```sh
It 'processes stdin'
  Data
    #|line one
    #|line two
  End
  When call my_func
  The output should eq "processed"
End
```

Variants: `Data:raw` (no expansion, default), `Data:expand` (expands variables).

## Mocking

### Function Mock (scoped to example)

```sh
It 'mocks a function'
  date() { echo "2024-01-15"; }
  When call get_timestamp
  The output should eq "Date: 2024-01-15"
End
```

### Command Mock (block syntax)

```sh
Mock curl
  echo '{"status": "ok"}'
End

It 'uses mocked curl'
  When run command curl https://api.example.com
  The output should eq '{"status": "ok"}'
End
```

### Intercept (stub before source)

```sh
Intercept begin

__begin__() {
  cat() { echo "stubbed"; }
}

It 'runs with stubs'
  When run source ./script.sh
  The output should eq "stubbed"
End
```

## Parameterized Tests

```sh
Parameters
  1  2  3
  5  5  10
End

It "adds $1 + $2 = $3"
  When call add "$1" "$2"
  The output should eq "$3"
End
```

Variants: `Parameters:matrix` (combinatorial), `Parameters:dynamic` (with `%data`).

## Custom Matchers

Create `spec/support/custom_matcher.sh`:

```sh
shellspec_syntax 'shellspec_matcher_regexp'
shellspec_matcher_regexp() {
  shellspec_matcher__match() {
    SHELLSPEC_EXPECT="$1"
    [ "${SHELLSPEC_SUBJECT+x}" ] || return 1
    expr "$SHELLSPEC_SUBJECT" : "$SHELLSPEC_EXPECT" > /dev/null || return 1
    return 0
  }
  shellspec_matcher__failure_message() {
    shellspec_putsn "expected: $1 match $2"
  }
  shellspec_matcher__failure_message_when_negated() {
    shellspec_putsn "expected: $1 not match $2"
  }
  shellspec_syntax_param count [ $# -eq 1 ] || return 0
  shellspec_matcher_do_match "$@"
}
```

Import in spec_helper: `import 'support/custom_matcher'`

## CLI Reference

| Flag                     | Description                                                          |
| ------------------------ | -------------------------------------------------------------------- |
| `--shell SHELL`          | Shell to run tests with                                              |
| `--format FMT`           | Output format: `progress` (default), `documentation`, `tap`, `junit` |
| `--output DIR`           | Output directory for report files                                    |
| `--jobs N`               | Parallel execution                                                   |
| `--example "pattern"`    | Filter by example name                                               |
| `--focus`                | Run only focused (`f`-prefixed) examples                             |
| `--quick`                | Run failed tests first                                               |
| `--repair`               | Run only previously failed tests                                     |
| `--next`                 | Stop at first failure                                                |
| `--random TYPE`          | Randomize order (`specfiles`, `examples`)                            |
| `--seed N`               | Random seed                                                          |
| `--kcov`                 | Enable code coverage (requires kcov v35+)                            |
| `--docker IMAGE`         | Run inside Docker container                                          |
| `-C DIR` / `--chdir DIR` | Change directory before running                                      |
| `--require FILE`         | Require helper file                                                  |
| `--init`                 | Initialize project structure                                         |
| `--syntax-check`         | Check spec syntax without running                                    |
| `--list examples`        | List examples without running                                        |

## Code Coverage

Requires [kcov](https://github.com/SimonKagworths/kcov) v35+. Only works with bash/zsh/ksh (not
pure sh).

```sh
vendor/shellspec-0.28.1/shellspec --kcov
# Reports output to coverage/ directory
```

## Tips

- Spec files must be named `*_spec.sh` by convention.
- `Include ./path/to/script.sh` to source code under test.
- Use `When run source` for scripts that call `exit`.
- Use `When call` for functions (stays in current shell context).
- The project root is detected by traversing up to find `.shellspec`.
- Environment vars: `setenv NAME=value` / `unsetenv NAME` in spec_helper.
