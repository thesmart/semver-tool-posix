# semver_validate.sh — POSIX semver validation and part extraction
#
# Provides:
#   validate_version <version>         — prints normalized version or exits with error
#   validate_version_parts <version>   — sets _V_MAJOR _V_MINOR _V_PATCH _V_PREREL _V_BUILD
#   is_nat <string>                    — returns 0 if non-negative integer (no leading zeros)
#   is_null <string>                   — returns 0 if empty string
#
# Uses _sv_ prefix for internal variables.

# --- regex building blocks ---
_SV_NAT='0|[1-9][0-9]*'
_SV_ALPHANUM='[0-9]*[A-Za-z-][0-9A-Za-z-]*'
_SV_IDENT="${_SV_NAT}|${_SV_ALPHANUM}"
_SV_FIELD='[0-9A-Za-z-][0-9A-Za-z-]*'

# Full semver regex for expr (BRE syntax — no alternation with |, so we use grep -E)
# We validate using grep -E with ERE.
SEMVER_REGEX="^[vV]?(${_SV_NAT})\.(${_SV_NAT})\.(${_SV_NAT})(\-(${_SV_IDENT})(\.(${_SV_IDENT}))*)?(\+${_SV_FIELD}(\.${_SV_FIELD})*)?$"

is_nat() {
  case "$1" in
    0) return 0 ;;
    [1-9]) return 0 ;;
    [1-9][0-9]|[1-9][0-9][0-9]|[1-9][0-9][0-9][0-9]|[1-9][0-9][0-9][0-9][0-9]|[1-9][0-9][0-9][0-9][0-9][0-9]|[1-9][0-9][0-9][0-9][0-9][0-9][0-9]|[1-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]|[1-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]) return 0 ;;
    *) return 1 ;;
  esac
}

is_null() {
  [ -z "$1" ]
}

# _sv_check_semver <version>
# Returns 0 if version matches SEMVER_REGEX, 1 otherwise.
_sv_check_semver() {
  printf '%s\n' "$1" | grep -Eq "$SEMVER_REGEX"
}

# validate_version <version>
# Prints the normalized version (v/V prefix stripped) to stdout.
# Exits with error if invalid.
validate_version() {
  if _sv_check_semver "$1"; then
    _sv_tmp="${1#[vV]}"
    printf '%s\n' "$_sv_tmp"
  else
    printf '%s\n' "version $1 does not match the semver scheme 'X.Y.Z(-PRERELEASE)(+BUILD)'. See help for more information." >&2
    exit 1
  fi
}

# validate_version_parts <version>
# Sets: _V_MAJOR _V_MINOR _V_PATCH _V_PREREL _V_BUILD
# _V_PREREL includes the leading "-" if present.
# _V_BUILD includes the leading "+" if present.
# Exits with error if invalid.
validate_version_parts() {
  _sv_check_semver "$1" || {
    printf '%s\n' "version $1 does not match the semver scheme 'X.Y.Z(-PRERELEASE)(+BUILD)'. See help for more information." >&2
    exit 1
  }

  _sv_ver="${1#[vV]}"

  # Extract build metadata (everything after +)
  case "$_sv_ver" in
    *+*) _V_BUILD="+${_sv_ver#*+}"; _sv_ver="${_sv_ver%%+*}" ;;
    *)   _V_BUILD="" ;;
  esac

  # Extract prerelease (everything after first - in remaining)
  # But we must be careful: the release part is X.Y.Z, then - starts prerelease
  _sv_release="${_sv_ver%%[-]*}"

  # Check if there actually is a prerelease part (release part must be X.Y.Z exactly)
  # We need to find the first '-' after the X.Y.Z portion
  case "$_sv_ver" in
    "${_sv_release}"-*)
      _V_PREREL="-${_sv_ver#"${_sv_release}"-}"
      ;;
    *)
      _V_PREREL=""
      ;;
  esac

  # Split release into major.minor.patch
  _V_MAJOR="${_sv_release%%.*}"
  _sv_rest="${_sv_release#*.}"
  _V_MINOR="${_sv_rest%%.*}"
  _V_PATCH="${_sv_rest#*.}"
}

# validate_version_parts2 <version>
# Same as validate_version_parts but sets _V2_* variables.
validate_version_parts2() {
  _sv_check_semver "$1" || {
    printf '%s\n' "version $1 does not match the semver scheme 'X.Y.Z(-PRERELEASE)(+BUILD)'. See help for more information." >&2
    exit 1
  }

  _sv_ver="${1#[vV]}"

  case "$_sv_ver" in
    *+*) _V2_BUILD="+${_sv_ver#*+}"; _sv_ver="${_sv_ver%%+*}" ;;
    *)   _V2_BUILD="" ;;
  esac

  _sv_release="${_sv_ver%%[-]*}"

  case "$_sv_ver" in
    "${_sv_release}"-*)
      _V2_PREREL="-${_sv_ver#"${_sv_release}"-}"
      ;;
    *)
      _V2_PREREL=""
      ;;
  esac

  _V2_MAJOR="${_sv_release%%.*}"
  _sv_rest="${_sv_release#*.}"
  _V2_MINOR="${_sv_rest%%.*}"
  _V2_PATCH="${_sv_rest#*.}"
}
