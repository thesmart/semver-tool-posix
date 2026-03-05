# semver-tool-posix

A POSIX-compliant, zero-dependencies shell utility for manipulating
[Semantic Versioning 2.0.0](https://semver.org/) strings.

[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)

> Forked from
> [fsaintjacques/semver-tool@v3.4.0](https://github.com/fsaintjacques/semver-tool/tree/3.4.0)

## Features

- **Bump** version components (major, minor, patch, prerelease, build, release)
- **Extract** specific parts from a version string
- **Compare** two versions
- **Diff** to identify the most significant difference between two versions
- **Validate** version strings against the semver 2.x spec
- **Tested** with nearly 100% functional coverage
- **POSIX** compliant, runs anywhere

Can be combined with `git` pre-commit hooks to guarantee correct versioning.

## Installation

### One-liner

```sh
# install to `/usr/local/bin`
curl -fsSL https://raw.githubusercontent.com/thesmart/semver-tool-posix/main/bin/install.sh | sh
# install to user dir `~/.local/bin`
curl -fsSL https://raw.githubusercontent.com/thesmart/semver-tool-posix/main/bin/install.sh | sh -s -- --prefix ~/.local
```

### From source

```sh
git clone https://github.com/thesmart/semver-tool-posix.git
cd semver-tool-posix
make install
```

## Usage

```
semver bump major <version>
semver bump minor <version>
semver bump patch <version>
semver bump prerel|prerelease [<prerel>] <version>
semver bump build <build> <version>
semver bump release <version>
semver get major|minor|patch|prerel|build|release <version>
semver compare <version> <other_version>
semver diff <version> <other_version>
semver validate <version>
semver --help
semver --version
```

### Version Format

A version must match `X.Y.Z[-PRERELEASE][+BUILD]` where X, Y, and Z are non-negative integers.

- **PRERELEASE** — dot-separated identifiers of alphanumeric characters and hyphens, introduced by
  `-`
- **BUILD** — dot-separated identifiers of alphanumeric characters and hyphens, introduced by `+`

## Examples

### Bumping

```sh
$ semver bump patch 0.1.0
0.1.1
$ semver bump minor 0.1.1
0.2.0
$ semver bump major 0.2.1
1.0.0
$ semver bump prerel rc.1 1.0.1
1.0.1-rc.1
$ semver bump prerel 1.0.1-rc.1+build4423
1.0.1-rc.2
$ semver bump build build.051 1.0.1-rc1.1.0
1.0.1-rc1.1.0+build.051
$ semver bump release v0.1.0-SNAPSHOT
0.1.0
```

### Comparing

```sh
$ semver compare 1.0.1-rc1.1.0+build.051 1.0.1
-1
$ semver compare v1.0.1-rc1.1.0+build.051 V1.0.1-rc1.1.0
0
$ semver compare 1.0.1-rc1.1.0+build.051 1.0.1-rb1.1.0
1
```

### Diffing

```sh
$ semver diff 1.0.1-rc1.1.0+build.051 1.0.1
prerelease
$ semver diff 10.1.4-rc4 10.4.2-rc1
minor
```

### Extracting

```sh
$ semver get major 1.2.3
1
$ semver get minor 1.2.3
2
$ semver get patch 1.2.3
3
$ semver get prerel 1.2.3-rc.4
rc.4
$ semver get build 1.2.3-rc.4+build.567
build.567
$ semver get release 1.2.3-rc.4+build.567
1.2.3
```

### Validating

```sh
$ semver validate 1.0.0
valid
$ semver validate 1
invalid
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for project structure, shell conventions, and development
workflow.

## License

[Apache License 2.0](LICENSE)
