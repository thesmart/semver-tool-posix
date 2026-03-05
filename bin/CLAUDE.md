# bin/

Build output and build tooling.

- **semver** — Built artifact. Single bundled script produced by `build.sh`. Git-ignored.
- **build.sh** — Build script. Bundles `src/` modules into `semver` and stamps the version from
  the root `VERSION` file.
- **install.sh** — Curl-pipe installer for end users.
