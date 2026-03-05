#shellcheck shell=sh
Describe 'semver general'
  It 'shows help with --help'
    When run command sh ./src/semver --help
    The first line of output should eq "Usage:"
  End

  It 'shows help with --help and extra args'
    When run command sh ./src/semver --help bump major 1.2.3
    The first line of output should eq "Usage:"
  End

  It 'shows version with --version'
    When run command sh ./src/semver --version
    The output should start with "semver:"
  End

  It 'exits with failure when no arguments'
    When run command sh ./src/semver
    The status should be failure
    The stderr should be present
  End
End
