#shellcheck shell=sh
Describe 'semver compare'
  It 'compares released versions (less)'
    When run command sh ./src/semver compare 0.2.1 0.2.2
    The output should eq "-1"
  End

  It 'compares released versions (equal)'
    When run command sh ./src/semver compare 1.2.1 1.2.1
    The output should eq "0"
  End

  It 'compares released versions (greater)'
    When run command sh ./src/semver compare 0.3.1 0.2.5
    The output should eq "1"
  End

  It 'fails on bad version in compare'
    When run command sh ./src/semver compare 1.1.1-rc1+build2 1.1.1-rc1+
    The status should be failure
    The stderr should be present
  End

  Describe 'precedence (spec 11)'
    It 'compares 1.0.0-alpha < 1.0.0-alpha.1'
      When run command sh ./src/semver compare 1.0.0-alpha 1.0.0-alpha.1
      The output should eq "-1"
    End

    It 'compares 1.0.0-alpha.1 < 1.0.0-alpha.beta'
      When run command sh ./src/semver compare 1.0.0-alpha.1 1.0.0-alpha.beta
      The output should eq "-1"
    End

    It 'compares 1.0.0-alpha.beta < 1.0.0-beta'
      When run command sh ./src/semver compare 1.0.0-alpha.beta 1.0.0-beta
      The output should eq "-1"
    End

    It 'compares 1.0.0-beta < 1.0.0-beta.2'
      When run command sh ./src/semver compare 1.0.0-beta 1.0.0-beta.2
      The output should eq "-1"
    End

    It 'compares 1.0.0-beta.2 < 1.0.0-beta.11'
      When run command sh ./src/semver compare 1.0.0-beta.2 1.0.0-beta.11
      The output should eq "-1"
    End

    It 'compares 1.0.0-beta.11 < 1.0.0-rc.1'
      When run command sh ./src/semver compare 1.0.0-beta.11 1.0.0-rc.1
      The output should eq "-1"
    End

    It 'compares 1.0.0-rc.1 < 1.0.0'
      When run command sh ./src/semver compare 1.0.0-rc.1 1.0.0
      The output should eq "-1"
    End

    It 'compares 1.0.0 > 1.0.0-rc.1'
      When run command sh ./src/semver compare 1.0.0 1.0.0-rc.1
      The output should eq "1"
    End
  End

  It 'compares numeric vs alpha pre-release'
    When run command sh ./src/semver compare 1.0.0-alpha 1.0.0-666
    The output should eq "1"
  End

  It 'compares equal versions'
    When run command sh ./src/semver compare 1.0.0 1.0.0
    The output should eq "0"
  End

  It 'ignores pre-release when patch differs'
    When run command sh ./src/semver compare 1.0.1 1.0.0-rc1
    The output should eq "1"
  End

  It 'compares alpha pre-release ids lexically'
    When run command sh ./src/semver compare 1.0.0-beta2 1.0.0-beta11
    The output should eq "1"
  End

  It 'compares numeric pre-release ids numerically'
    When run command sh ./src/semver compare 1.0.0-2 1.0.0-11
    The output should eq "-1"
  End

  It 'compares less, ignoring build metadata'
    When run command sh ./src/semver compare 1.0.0-beta1+a 1.0.0-beta2+z
    The output should eq "-1"
  End

  It 'compares equal, ignoring build metadata'
    When run command sh ./src/semver compare 1.0.0-beta2+x 1.0.0-beta2+y
    The output should eq "0"
  End

  It 'compares greater, ignoring build metadata'
    When run command sh ./src/semver compare 1.0.0-12.beta2+x 1.0.0-11.beta2+y
    The output should eq "1"
  End

  It 'compares equal ignoring build metadata w/no pre-release'
    When run command sh ./src/semver compare 1.0.0+x 1.0.0+y
    The output should eq "0"
  End
End
