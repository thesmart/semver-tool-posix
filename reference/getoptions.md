# getoptions

**getoptions** is an options parser written in POSIX-compliant shell script.

## Usage Example

```sh
#!/bin/sh
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Load getoptions library
eval "$(sh "${SCRIPT_DIR}/getoptions.sh" -)"

VERSION="0.1.0"

parser_definition() {
  setup   REST help:usage -- "Usage: example.sh [options]... [arguments]..." ''
  msg -- 'Options:'
  flag    FLAG    -f --flag                 -- "takes no arguments"
  param   PARAM   -p --param                -- "takes one argument"
  option  OPTION  -o --option on:"default"  -- "takes one optional argument"
  disp    :usage     --help
  disp    VERSION    --version
}

eval "$(getoptions parser_definition) exit 1"

echo "FLAG: $FLAG, PARAM: $PARAM, OPTION: $OPTION"
printf '%s\n' "$@" # rest arguments
```

It generates a simple [option parser code](#how-to-see-the-option-parser-code) internally and
parses the following arguments.

```console
$ example.sh -f --flag -p value --param value -o --option -ovalue --option=value 1 2 3
FLAG: 1, PARAM: value, OPTION: value
1
2
3
```

Automatic help generation is also provided.

```console
$ example.sh --help

Usage: example.sh [options]... [arguments]...

Options:
  -f, --flag                  takes no arguments
  -p, --param PARAM           takes one argument
  -o, --option[=OPTION]       takes one optional argument
      --help
      --version
```

---

**AVOID** reading the [getoptions.sh](../src/getoptions.sh) source code, unless explicitly asked.
