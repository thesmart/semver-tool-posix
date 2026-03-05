# semver_compare.sh — compare two semver versions
#
# Provides:
#   command_compare <version> <other_version>
#   compare_version <version> <other_version>
#
# Requires: semver_validate.sh sourced first.
# Uses _sc_ prefix for internal variables.

order_nat() {
  if [ "$1" -lt "$2" ]; then
    printf '%s\n' "-1"
  elif [ "$1" -gt "$2" ]; then
    printf '%s\n' "1"
  else
    printf '%s\n' "0"
  fi
}

order_string() {
  if [ "$1" = "$2" ]; then
    printf '%s\n' "0"
  elif [ "$(printf '%s\n%s\n' "$1" "$2" | sort | head -n1)" = "$1" ]; then
    printf '%s\n' "-1"
  else
    printf '%s\n' "1"
  fi
}

# _sc_compare_fields <left_fields> <right_fields>
# Fields are dot-separated strings (e.g., "rc.1.2" and "rc.1.3").
# Compares field by field per semver 2.0.0 spec.
_sc_compare_fields() {
  _sc_left="$1"
  _sc_right="$2"

  while :; do
    # Extract first field from each
    case "$_sc_left" in
      *.*) _sc_lf="${_sc_left%%.*}"; _sc_left="${_sc_left#*.}" ;;
      *)   _sc_lf="$_sc_left"; _sc_left="" ;;
    esac
    case "$_sc_right" in
      *.*) _sc_rf="${_sc_right%%.*}"; _sc_right="${_sc_right#*.}" ;;
      *)   _sc_rf="$_sc_right"; _sc_right="" ;;
    esac

    # Both exhausted
    if is_null "$_sc_lf" && is_null "$_sc_rf"; then
      printf '%s\n' "0"
      return
    fi
    # Left exhausted (shorter), right still has fields
    if is_null "$_sc_lf"; then
      printf '%s\n' "-1"
      return
    fi
    # Right exhausted (shorter), left still has fields
    if is_null "$_sc_rf"; then
      printf '%s\n' "1"
      return
    fi

    # Both are natural numbers — compare numerically
    if is_nat "$_sc_lf" && is_nat "$_sc_rf"; then
      _sc_ord="$(order_nat "$_sc_lf" "$_sc_rf")"
      if [ "$_sc_ord" -ne 0 ]; then
        printf '%s\n' "$_sc_ord"
        return
      fi
      # equal, continue to next field
    elif is_nat "$_sc_lf"; then
      # numeric < non-numeric
      printf '%s\n' "-1"
      return
    elif is_nat "$_sc_rf"; then
      # non-numeric > numeric
      printf '%s\n' "1"
      return
    else
      # Both non-numeric — compare lexically
      _sc_ord="$(order_string "$_sc_lf" "$_sc_rf")"
      if [ "$_sc_ord" -ne 0 ]; then
        printf '%s\n' "$_sc_ord"
        return
      fi
    fi

    # Fields equal, but check if one side is exhausted and other isn't
    if is_null "$_sc_left" && is_null "$_sc_right"; then
      # No more fields on either side, they're equal so far
      continue
    fi
  done
}

# compare_version <version> <other_version>
# Prints -1, 0, or 1.
compare_version() {
  validate_version_parts "$1"
  _sc_v1_major="$_V_MAJOR"
  _sc_v1_minor="$_V_MINOR"
  _sc_v1_patch="$_V_PATCH"
  _sc_v1_prerel="$_V_PREREL"

  validate_version_parts "$2"
  _sc_v2_major="$_V_MAJOR"
  _sc_v2_minor="$_V_MINOR"
  _sc_v2_patch="$_V_PATCH"
  _sc_v2_prerel="$_V_PREREL"

  # Compare major.minor.patch numerically
  _sc_ord="$(order_nat "$_sc_v1_major" "$_sc_v2_major")"
  if [ "$_sc_ord" -ne 0 ]; then printf '%s\n' "$_sc_ord"; return; fi

  _sc_ord="$(order_nat "$_sc_v1_minor" "$_sc_v2_minor")"
  if [ "$_sc_ord" -ne 0 ]; then printf '%s\n' "$_sc_ord"; return; fi

  _sc_ord="$(order_nat "$_sc_v1_patch" "$_sc_v2_patch")"
  if [ "$_sc_ord" -ne 0 ]; then printf '%s\n' "$_sc_ord"; return; fi

  # Strip leading "-" from prerelease
  _sc_pre1="${_sc_v1_prerel#-}"
  _sc_pre2="${_sc_v2_prerel#-}"

  # Both have no prerelease — equal
  if [ -z "$_sc_pre1" ] && [ -z "$_sc_pre2" ]; then
    printf '%s\n' "0"
    return
  fi
  # Only left has no prerelease — left is greater (release > prerelease)
  if [ -z "$_sc_pre1" ]; then
    printf '%s\n' "1"
    return
  fi
  # Only right has no prerelease — right is greater
  if [ -z "$_sc_pre2" ]; then
    printf '%s\n' "-1"
    return
  fi

  # Compare prerelease fields
  _sc_compare_fields "$_sc_pre1" "$_sc_pre2"
}

command_compare() {
  case $# in
    2) ;;
    *) usage_help ;;
  esac

  # Validate both versions (prints normalized, but we just need to check validity)
  validate_version "$1" >/dev/null
  validate_version "$2" >/dev/null

  compare_version "$1" "$2"
  exit 0
}
