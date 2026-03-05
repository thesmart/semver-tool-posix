# semver_get.sh — extract parts from a semver version string
#
# Provides:
#   command_get <part> <version>
#
# Requires: semver_validate.sh sourced first.
# Uses _sg_ prefix for internal variables.

# normalize_part <part>
# Normalizes "prerelease" to "prerel".
normalize_part() {
  case "$1" in
    prerelease) printf '%s\n' "prerel" ;;
    *)          printf '%s\n' "$1" ;;
  esac
}

command_get() {
  if [ "$#" -ne 2 ] || [ -z "$1" ] || [ -z "$2" ]; then
    usage_help
  fi

  _sg_part="$1"
  _sg_version="$2"

  validate_version_parts "$_sg_version"
  _sg_major="$_V_MAJOR"
  _sg_minor="$_V_MINOR"
  _sg_patch="$_V_PATCH"
  _sg_prerel="${_V_PREREL#-}"
  _sg_build="${_V_BUILD#+}"
  _sg_release="${_sg_major}.${_sg_minor}.${_sg_patch}"

  _sg_part="$(normalize_part "$_sg_part")"

  case "$_sg_part" in
    major)   printf '%s\n' "$_sg_major" ;;
    minor)   printf '%s\n' "$_sg_minor" ;;
    patch)   printf '%s\n' "$_sg_patch" ;;
    prerel)  printf '%s\n' "$_sg_prerel" ;;
    build)   printf '%s\n' "$_sg_build" ;;
    release) printf '%s\n' "$_sg_release" ;;
    *)       usage_help ;;
  esac

  exit 0
}
