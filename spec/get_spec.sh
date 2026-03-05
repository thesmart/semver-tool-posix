#shellcheck shell=sh
Describe 'semver get'
  It 'gets major'
    When run command sh ./src/semver get major 0.2.1-rc1.0+build-1234
    The output should eq "0"
  End

  It 'gets minor'
    When run command sh ./src/semver get minor 0.2.1-rc1.0+build-1234
    The output should eq "2"
  End

  It 'gets patch'
    When run command sh ./src/semver get patch 0.2.1-rc1.0+build-1234
    The output should eq "1"
  End

  It 'gets prerel'
    When run command sh ./src/semver get prerel 0.2.1-rc1.-0+build-1234
    The output should eq "rc1.-0"
  End

  It 'gets prerelease (synonym)'
    When run command sh ./src/semver get prerelease 0.2.1-rc1.-0+build-1234
    The output should eq "rc1.-0"
  End

  It 'gets build'
    When run command sh ./src/semver get build 0.2.1-rc1.0+build-0234
    The output should eq "build-0234"
  End

  It 'gets release'
    When run command sh ./src/semver get release 0.2.1-rc1.0+build-0234
    The output should eq "0.2.1"
  End

  It 'fails on bad version in get minor'
    When run command sh ./src/semver get minor 1.2.
    The status should be failure
    The stderr should be present
  End

  It 'fails on missing prerel'
    When run command sh ./src/semver get patch 1.2.4-
    The status should be failure
    The stderr should be present
  End

  It 'fails on missing build'
    When run command sh ./src/semver get build 1.2.4+
    The status should be failure
    The stderr should be present
  End

  Describe 'pre-release parts (spec 9)'
    It 'gets valid pre-release (alpha)'
      When run command sh ./src/semver get prerel 1.0.0-alpha
      The output should eq "alpha"
    End

    It 'gets valid pre-release (alpha & numeric)'
      When run command sh ./src/semver get prerel 1.0.0-alpha.1
      The output should eq "alpha.1"
    End

    It 'gets valid pre-release (alpha w/zero & numeric)'
      When run command sh ./src/semver get prerel 1.0.0-0alpha.1
      The output should eq "0alpha.1"
    End

    It 'gets valid pre-release (numerics)'
      When run command sh ./src/semver get prerel 1.0.0-0.3.7
      The output should eq "0.3.7"
    End

    It 'gets valid pre-release (complex w/alpha)'
      When run command sh ./src/semver get prerel 1.0.0-x.7.z.92
      The output should eq "x.7.z.92"
    End

    It 'gets valid pre-release (w/hyphen)'
      When run command sh ./src/semver get prerel 1.0.0-x-.7.--z.92-
      The output should eq "x-.7.--z.92-"
    End

    It 'fails on invalid char $ in pre-release'
      When run command sh ./src/semver get prerel "1.0.0-x.7.z\$.92"
      The status should be failure
    The stderr should be present
    End

    It 'fails on invalid char _ in pre-release'
      When run command sh ./src/semver get prerel "1.0.0-x_.7.z.92"
      The status should be failure
    The stderr should be present
    End

    It 'fails on leading zero in pre-release'
      When run command sh ./src/semver get prerel "1.0.0-x.7.z.092"
      The status should be failure
    The stderr should be present
    End

    It 'fails on two leading zeros in pre-release'
      When run command sh ./src/semver get prerel "1.0.0-x.07.z.092"
      The status should be failure
    The stderr should be present
    End

    It 'fails on empty identifier in pre-release (embedded)'
      When run command sh ./src/semver get prerel "1.0.0-x.7.z..92"
      The status should be failure
    The stderr should be present
    End

    It 'fails on empty identifier in pre-release (leading)'
      When run command sh ./src/semver get prerel "1.0.0-.x.7.z.92"
      The status should be failure
    The stderr should be present
    End

    It 'fails on empty identifier in pre-release (trailing)'
      When run command sh ./src/semver get prerel "1.0.0-x.7.z.92."
      The status should be failure
    The stderr should be present
    End
  End

  Describe 'build-metadata parts (spec 10)'
    It 'gets valid build-metadata (numeric)'
      When run command sh ./src/semver get build 1.0.0-alpha+001
      The output should eq "001"
    End

    It 'gets valid build-metadata (numeric after patch)'
      When run command sh ./src/semver get build 1.0.0+20130313144700
      The output should eq "20130313144700"
    End

    It 'gets valid build-metadata (alpha & numeric)'
      When run command sh ./src/semver get build 1.0.0-beta+exp.sha.5114f85
      The output should eq "exp.sha.5114f85"
    End

    It 'gets valid build-metadata (alpha & numeric after patch)'
      When run command sh ./src/semver get build 1.0.0+exp.sha.5114f85
      The output should eq "exp.sha.5114f85"
    End

    It 'gets valid build-metadata (w/leading zero)'
      When run command sh ./src/semver get build 1.0.0-x.7.z.92+02
      The output should eq "02"
    End

    It 'gets valid build-metadata (w/leading hyphen)'
      When run command sh ./src/semver get build 1.0.0-x.7.z.92+-alpha-2
      The output should eq "-alpha-2"
    End

    It 'gets valid build-metadata (w/trailing hyphen)'
      When run command sh ./src/semver get build 1.0.0-x.7.z.92+-alpha-2-
      The output should eq "-alpha-2-"
    End

    It 'fails on invalid char $ in build-metadata'
      When run command sh ./src/semver get build "1.0.0-x+7.z\$.92"
      The status should be failure
    The stderr should be present
    End

    It 'fails on invalid char _ in build-metadata'
      When run command sh ./src/semver get build "1.0.0-x+7.z.92._"
      The status should be failure
    The stderr should be present
    End

    It 'fails on invalid char after patch in build-metadata'
      When run command sh ./src/semver get build "1.0.0+7.z\$.92"
      The status should be failure
    The stderr should be present
    End

    It 'fails on empty identifier in build-metadata (embedded)'
      When run command sh ./src/semver get build "1.0.0-x+7.z..92"
      The status should be failure
    The stderr should be present
    End

    It 'fails on empty identifier in build-metadata (leading)'
      When run command sh ./src/semver get build "1.0.0+.x.7.z.92"
      The status should be failure
    The stderr should be present
    End

    It 'fails on empty identifier in build-metadata (trailing)'
      When run command sh ./src/semver get build "1.0.0-x.7+z.92."
      The status should be failure
    The stderr should be present
    End
  End
End
