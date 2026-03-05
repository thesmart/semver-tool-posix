#shellcheck shell=sh
Describe 'semver diff'
  It 'diffs versions (major)'
    When run command sh ./src/semver diff 1.2.3 2.3.4
    The output should eq "major"
  End

  It 'diffs versions (minor)'
    When run command sh ./src/semver diff 1.2.3 1.3.4
    The output should eq "minor"
  End

  It 'diffs versions (patch)'
    When run command sh ./src/semver diff 1.2.3 1.2.4
    The output should eq "patch"
  End

  It 'diffs versions (prerelease)'
    When run command sh ./src/semver diff 1.2.3-alpha 1.2.3-beta
    The output should eq "prerelease"
  End

  It 'diffs versions (equal)'
    When run command sh ./src/semver diff 1.2.3 1.2.3
    The output should eq ""
  End
End
