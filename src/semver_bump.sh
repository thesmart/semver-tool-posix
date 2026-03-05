# semver_bump.sh — bump semver version components
#
# Provides:
#   command_bump <subcommand> [<arg>] <version>
#
# Requires: semver_validate.sh sourced first.
# Uses _sb_ prefix for internal variables.

# render_prerel <numeric> [<prefix>]
# Returns a prerelease field with a trailing numeric string.
render_prerel() {
  if [ -z "$2" ]; then
    printf '%s\n' "$1"
  else
    printf '%s\n' "${2}${1}"
  fi
}

# extract_prerel <prerel_string>
# Sets _sb_ep_prefix and _sb_ep_numeric.
# Extracts prefix and trailing numeric portions of a pre-release part.
extract_prerel() {
  _sb_ep_input="$1"

  # Try to match trailing digits
  # Use expr to extract trailing numeric part
  _sb_ep_numeric="$(expr "$_sb_ep_input" : '.*[.A-Za-z-]\([0-9][0-9]*\)$' 2>/dev/null)" || _sb_ep_numeric=""

  if [ -n "$_sb_ep_numeric" ]; then
    # prefix is everything before the trailing numeric
    _sb_ep_len=${#_sb_ep_numeric}
    _sb_ep_totallen=${#_sb_ep_input}
    _sb_ep_prefixlen=$((_sb_ep_totallen - _sb_ep_len))
    _sb_ep_prefix="$(printf '%s' "$_sb_ep_input" | cut -c1-"${_sb_ep_prefixlen}")"
  else
    # Check if it's purely numeric
    case "$_sb_ep_input" in
      [0-9]|[0-9][0-9]|[0-9][0-9][0-9]|[0-9][0-9][0-9][0-9]|[0-9][0-9][0-9][0-9][0-9]*)
        # Check if it's all digits
        _sb_ep_check="$(printf '%s' "$_sb_ep_input" | tr -d '0-9')"
        if [ -z "$_sb_ep_check" ]; then
          _sb_ep_numeric="$_sb_ep_input"
          _sb_ep_prefix=""
        else
          _sb_ep_prefix="$_sb_ep_input"
          _sb_ep_numeric=""
        fi
        ;;
      *)
        _sb_ep_prefix="$_sb_ep_input"
        _sb_ep_numeric=""
        ;;
    esac
  fi
}

# bump_prerel <proto> <previous_prerel>
# previous_prerel includes the leading "-" if present.
# Prints the new pre-release string (without leading "-").
bump_prerel() {
  _sb_proto="$1"
  _sb_prev="$2"

  # Case one: no trailing dot in prototype => simply replace
  case "$_sb_proto" in
    *.) ;;  # has trailing dot, continue below
    *)
      printf '%s\n' "$_sb_proto"
      return
      ;;
  esac

  # Discard trailing dot marker from prototype
  _sb_proto="${_sb_proto%.}"

  # Extract parts of previous pre-release (strip leading "-")
  _sb_prev_stripped="${_sb_prev#-}"
  extract_prerel "$_sb_prev_stripped"
  _sb_prev_prefix="$_sb_ep_prefix"
  _sb_prev_numeric="$_sb_ep_numeric"

  # Case two: dummy "+" indicates no prototype argument provided
  if [ "$_sb_proto" = "+" ]; then
    if [ -n "$_sb_prev_numeric" ]; then
      _sb_prev_numeric=$((_sb_prev_numeric + 1))
      render_prerel "$_sb_prev_numeric" "$_sb_prev_prefix"
    else
      render_prerel 1 "$_sb_prev_prefix"
    fi
    return
  fi

  # Case three: set, bump, or append using prototype prefix
  if [ "$_sb_prev_prefix" != "$_sb_proto" ]; then
    render_prerel 1 "$_sb_proto"
  elif [ -n "$_sb_prev_numeric" ]; then
    _sb_prev_numeric=$((_sb_prev_numeric + 1))
    render_prerel "$_sb_prev_numeric" "$_sb_prev_prefix"
  else
    render_prerel 1 "$_sb_prev_prefix"
  fi
}

command_bump() {
  _sb_command="$(normalize_part "$1")"

  case $# in
    2) case "$_sb_command" in
        major|minor|patch|prerel|release) _sb_sub_version="+."; _sb_version="$2" ;;
        *) usage_help ;;
       esac ;;
    3) case "$_sb_command" in
        prerel|build) _sb_sub_version="$2"; _sb_version="$3" ;;
        *) usage_help ;;
       esac ;;
    *) usage_help ;;
  esac

  validate_version_parts "$_sb_version"
  _sb_major="$_V_MAJOR"
  _sb_minor="$_V_MINOR"
  _sb_patch="$_V_PATCH"
  _sb_prerel="$_V_PREREL"
  _sb_build="$_V_BUILD"

  case "$_sb_command" in
    major) _sb_new="$((_sb_major + 1)).0.0" ;;
    minor) _sb_new="${_sb_major}.$((_sb_minor + 1)).0" ;;
    patch) _sb_new="${_sb_major}.${_sb_minor}.$((_sb_patch + 1))" ;;
    release) _sb_new="${_sb_major}.${_sb_minor}.${_sb_patch}" ;;
    prerel) _sb_new="$(validate_version "${_sb_major}.${_sb_minor}.${_sb_patch}-$(bump_prerel "$_sb_sub_version" "$_sb_prerel")")" ;;
    build) _sb_new="$(validate_version "${_sb_major}.${_sb_minor}.${_sb_patch}${_sb_prerel}+${_sb_sub_version}")" ;;
    *) usage_help ;;
  esac

  printf '%s\n' "$_sb_new"
  exit 0
}
