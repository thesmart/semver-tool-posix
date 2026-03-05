# semver_diff.sh — diff two semver versions
#
# Provides:
#   command_diff <version> <other_version>
#
# Requires: semver_validate.sh sourced first.
# Uses _sd_ prefix for internal variables.

command_diff() {
  validate_version_parts "$1"
  _sd_v1_major="$_V_MAJOR"
  _sd_v1_minor="$_V_MINOR"
  _sd_v1_patch="$_V_PATCH"
  _sd_v1_prerel="$_V_PREREL"
  _sd_v1_build="$_V_BUILD"

  validate_version_parts "$2"
  _sd_v2_major="$_V_MAJOR"
  _sd_v2_minor="$_V_MINOR"
  _sd_v2_patch="$_V_PATCH"
  _sd_v2_prerel="$_V_PREREL"
  _sd_v2_build="$_V_BUILD"

  if [ "$_sd_v1_major" != "$_sd_v2_major" ]; then
    printf '%s\n' "major"
  elif [ "$_sd_v1_minor" != "$_sd_v2_minor" ]; then
    printf '%s\n' "minor"
  elif [ "$_sd_v1_patch" != "$_sd_v2_patch" ]; then
    printf '%s\n' "patch"
  elif [ "$_sd_v1_prerel" != "$_sd_v2_prerel" ]; then
    printf '%s\n' "prerelease"
  elif [ "$_sd_v1_build" != "$_sd_v2_build" ]; then
    printf '%s\n' "build"
  fi
}
