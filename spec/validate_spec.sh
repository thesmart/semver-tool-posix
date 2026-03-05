#shellcheck shell=sh
Describe 'semver validate'
  It 'exits with failure when missing arg'
    When run command sh ./src/semver validate
    The status should be failure
    The stderr should be present
  End

  It 'exits with success for correct arg'
    When run command sh ./src/semver validate 1.2.2
    The status should be success
    The output should eq "valid"
  End

  It 'exits with failure for too many args'
    When run command sh ./src/semver validate 1.2.2 1.0.0
    The status should be failure
    The stderr should be present
  End

  It 'prints invalid for major only'
    When run command sh ./src/semver validate 1
    The output should eq "invalid"
  End

  It 'prints invalid for minor only'
    When run command sh ./src/semver validate 1.1
    The output should eq "invalid"
  End

  It 'prints valid for major/minor/patch'
    When run command sh ./src/semver validate 1.1.1
    The output should eq "valid"
  End

  It 'prints invalid with trailing dash'
    When run command sh ./src/semver validate 1.1.1-
    The output should eq "invalid"
  End

  It 'prints valid with pre-release'
    When run command sh ./src/semver validate 1.1.1-1
    The output should eq "valid"
  End

  It 'prints invalid with trailing plus'
    When run command sh ./src/semver validate 1.1.1+
    The output should eq "invalid"
  End

  It 'prints valid with build'
    When run command sh ./src/semver validate 1.1.1+1
    The output should eq "valid"
  End

  It 'prints valid with pre-release and build'
    When run command sh ./src/semver validate 1.1.1-1+1
    The output should eq "valid"
  End
End
