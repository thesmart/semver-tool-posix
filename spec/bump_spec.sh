#shellcheck shell=sh
Describe 'semver bump'
  Describe 'simple bumps'
    It 'bumps patch'
      When run command sh ./src/semver bump patch 0.2.1
      The output should eq "0.2.2"
    End

    It 'bumps minor'
      When run command sh ./src/semver bump minor 0.2.1
      The output should eq "0.3.0"
    End

    It 'bumps major'
      When run command sh ./src/semver bump major 0.2.1
      The output should eq "1.0.0"
    End

    It 'bumps major with leading v'
      When run command sh ./src/semver bump major v0.2.1
      The output should eq "1.0.0"
    End

    It 'bumps major with leading V'
      When run command sh ./src/semver bump major V0.2.1
      The output should eq "1.0.0"
    End
  End

  Describe 'release bumps'
    It 'bumps to release (no-op)'
      When run command sh ./src/semver bump release 0.2.1
      The output should eq "0.2.1"
    End

    It 'bumps to release (strip pre-release)'
      When run command sh ./src/semver bump release 0.2.1-rc1.0
      The output should eq "0.2.1"
    End

    It 'bumps to release (strip pre-release and build)'
      When run command sh ./src/semver bump release 0.2.1-rc1.0+build-1234
      The output should eq "0.2.1"
    End
  End

  Describe 'prerel bumps (explicit)'
    It 'sets prerel'
      When run command sh ./src/semver bump prerel rc.1 0.2.1
      The output should eq "0.2.1-rc.1"
    End

    It 'sets prerelease (synonym)'
      When run command sh ./src/semver bump prerelease rc.1 0.2.1
      The output should eq "0.2.1-rc.1"
    End

    It 'replaces and strips build metadata'
      When run command sh ./src/semver bump prerel rc.1 0.2.1-0.2+b13
      The output should eq "0.2.1-rc.1"
    End

    It 'strips build metadata'
      When run command sh ./src/semver bump prerel rc.1 0.2.1+b13
      The output should eq "0.2.1-rc.1"
    End
  End

  Describe 'build bumps'
    It 'replaces build metadata'
      When run command sh ./src/semver bump build b.1 0.2.1+b13
      The output should eq "0.2.1+b.1"
    End

    It 'preserves prerel, replaces build metadata'
      When run command sh ./src/semver bump build b.1 0.2.1-rc12+b13
      The output should eq "0.2.1-rc12+b.1"
    End
  End

  Describe 'error cases'
    It 'fails on extra arguments'
      When run command sh ./src/semver bump minor 9.8.7 0.1.2
      The status should be failure
    The stderr should be present
    End

    It 'fails on bad version in bump patch'
      When run command sh ./src/semver bump patch bogus
      The status should be failure
    The stderr should be present
    End
  End

  Describe 'version format (spec 2)'
    It 'accepts normal version'
      When run command sh ./src/semver bump release 1.9.0
      The output should eq "1.9.0"
    End

    It 'rejects leading zeros (major)'
      When run command sh ./src/semver bump release 01.9.1
      The status should be failure
    The stderr should be present
    End

    It 'rejects leading zeros (minor)'
      When run command sh ./src/semver bump release 1.09.1
      The status should be failure
    The stderr should be present
    End

    It 'rejects leading zeros (patch)'
      When run command sh ./src/semver bump release 1.9.01
      The status should be failure
    The stderr should be present
    End

    It 'rejects double zeros (patch)'
      When run command sh ./src/semver bump release 1.9.00
      The status should be failure
    The stderr should be present
    End

    It 'rejects invalid character (minor)'
      When run command sh ./src/semver bump release 1.9a.0
      The status should be failure
    The stderr should be present
    End

    It 'rejects invalid character (major)'
      When run command sh ./src/semver bump release -1.9.0
      The status should be failure
    The stderr should be present
    End
  End

  Describe 'semver spec rules'
    It 'bumps minor and zeros patch'
      When run command sh ./src/semver bump minor 1.9.1
      The output should eq "1.10.0"
    End

    It 'bumps major and zeros minor, patch'
      When run command sh ./src/semver bump major 1.9.1
      The output should eq "2.0.0"
    End
  End

  Describe 'pre-release validation'
    It 'rejects leading zero in pre-release'
      When run command sh ./src/semver bump prerel "x.7.z.092" "1.0.0"
      The status should be failure
    The stderr should be present
    End

    It 'rejects invalid character in pre-release'
      When run command sh ./src/semver bump prerel "x.=.z.92" "1.0.0"
      The status should be failure
    The stderr should be present
    End

    It 'rejects empty identifier in pre-release (embedded)'
      When run command sh ./src/semver bump prerel "x.7.z..92" "1.0.0"
      The status should be failure
    The stderr should be present
    End

    It 'rejects empty identifier in pre-release (leading)'
      When run command sh ./src/semver bump prerel ".x.7.z.92" "1.0.0"
      The status should be failure
    The stderr should be present
    End

    It 'rejects pre-release on invalid version'
      When run command sh ./src/semver bump prerel "x.7.z.92" "1.00.0"
      The status should be failure
    The stderr should be present
    End
  End

  Describe 'build-metadata validation'
    It 'rejects invalid char $ in build-metadata'
      When run command sh ./src/semver bump build "7.z\$.92" "1.0.0"
      The status should be failure
    The stderr should be present
    End

    It 'rejects invalid char _ in build-metadata'
      When run command sh ./src/semver bump build "7.z.92._" "1.0.0"
      The status should be failure
    The stderr should be present
    End

    It 'rejects empty identifier in build-metadata (embedded)'
      When run command sh ./src/semver bump build "7.z..92" "1.0.0"
      The status should be failure
    The stderr should be present
    End

    It 'rejects empty identifier in build-metadata (leading)'
      When run command sh ./src/semver bump build ".x.7.z.92" "1.0.0"
      The status should be failure
    The stderr should be present
    End

    It 'rejects empty identifier in build-metadata (trailing)'
      When run command sh ./src/semver bump build "z.92." "1.0.0"
      The status should be failure
    The stderr should be present
    End
  End

  Describe 'prerel explicit prefix numbering'
    It 'adds numeric id'
      When run command sh ./src/semver bump prerel . 0.2.1
      The output should eq "0.2.1-1"
    End

    It 'replaces with numeric id'
      When run command sh ./src/semver bump prerel . 0.2.1-alpha
      The output should eq "0.2.1-1"
    End

    It 'increments numeric id'
      When run command sh ./src/semver bump prerel . 0.2.1-1
      The output should eq "0.2.1-2"
    End

    It 'adds new pre-release part'
      When run command sh ./src/semver bump prerel rc. 0.2.1
      The output should eq "0.2.1-rc1"
    End

    It 'adds new pre-release part with separated numeric id'
      When run command sh ./src/semver bump prerel rc.. 0.2.1
      The output should eq "0.2.1-rc.1"
    End

    It 'adds numeric id to existing pre-release, similar prefix'
      When run command sh ./src/semver bump prerel rc.v. 0.2.1-rc.2
      The output should eq "0.2.1-rc.v1"
    End

    It 'adds numeric id to existing pre-release, similar trailing id'
      When run command sh ./src/semver bump prerel rc.3. 0.2.1-rc.3
      The output should eq "0.2.1-rc.31"
    End

    It 'adds numeric id to existing pre-release, similar trailing id with dot'
      When run command sh ./src/semver bump prerel rc.3.. 0.2.1-rc.3
      The output should eq "0.2.1-rc.3.1"
    End

    It 'adds numeric id to existing pre-release'
      When run command sh ./src/semver bump prerel rc. 0.2.1-rc
      The output should eq "0.2.1-rc1"
    End

    It 'replaces with new pre-release part'
      When run command sh ./src/semver bump prerel rc. 0.2.1-alpha
      The output should eq "0.2.1-rc1"
    End

    It 'increments numeric id in pre-release part'
      When run command sh ./src/semver bump prerel rc. 0.2.1-rc1
      The output should eq "0.2.1-rc2"
    End

    It 'increments numeric id in pre-release part with dot'
      When run command sh ./src/semver bump prerel rc.. 0.2.1-rc.1
      The output should eq "0.2.1-rc.2"
    End

    It 'increments numeric id, multiple ids'
      When run command sh ./src/semver bump prerel v6.rc. 0.2.1-v6.rc1
      The output should eq "0.2.1-v6.rc2"
    End

    It 'increments numeric id with dot, multiple ids'
      When run command sh ./src/semver bump prerel 4.rc.. 0.2.1-4.rc.1
      The output should eq "0.2.1-4.rc.2"
    End
  End

  Describe 'prerel explicit prefix errors'
    It 'rejects bad pre-release arg'
      When run command sh ./src/semver bump prerel .rc. 0.2.1-rc.1
      The status should be failure
    The stderr should be present
    End

    It 'rejects bad version'
      When run command sh ./src/semver bump prerel rc. 0.2.1-.rc.1
      The status should be failure
    The stderr should be present
    End

    It 'rejects 2-dot pre-release arg (inc)'
      When run command sh ./src/semver bump prerel .. 0.2.1-rc.1
      The status should be failure
    The stderr should be present
    End

    It 'rejects 2-dot pre-release arg (add)'
      When run command sh ./src/semver bump prerel .. 0.2.1
      The status should be failure
    The stderr should be present
    End
  End

  Describe 'prerel implicit numbering (no-arg)'
    It 'increments numeric id, no-arg'
      When run command sh ./src/semver bump prerel 0.2.1-rc.1
      The output should eq "0.2.1-rc.2"
    End

    It 'adds numeric id, no-arg'
      When run command sh ./src/semver bump prerel 0.2.1
      The output should eq "0.2.1-1"
    End

    It 'appends numeric id to pre-release, no-arg'
      When run command sh ./src/semver bump prerel 0.2.1-alpha
      The output should eq "0.2.1-alpha1"
    End

    It 'increments numeric id, no-arg (pure number)'
      When run command sh ./src/semver bump prerel 0.2.1-1
      The output should eq "0.2.1-2"
    End
  End

  Describe 'prerel implicit errors'
    It 'rejects bad version'
      When run command sh ./src/semver bump prerel 0.2.1-rc.
      The status should be failure
    The stderr should be present
    End
  End
End
