fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios beta
```
fastlane ios beta
```
Push a new beta build to TestFlight (Used by CircleCI)
### ios tfbeta
```
fastlane ios tfbeta
```
Push beta build to TestFlight from developer machine using testflight build numbers
### ios localbeta
```
fastlane ios localbeta
```
Push beta build to TestFlight from developer machine using local build number
### ios certificates
```
fastlane ios certificates
```
Installs the certificates and profiles locally
### ios test
```
fastlane ios test
```
Runs all the tests
### ios refresh_dsyms_beta
```
fastlane ios refresh_dsyms_beta
```
Upload latest iTunes Connect bitcode symbol file to crashlytics
### ios run_spm_pre_script
```
fastlane ios run_spm_pre_script
```
Runs the SPM pre-build script.

Pass in a value for `prod` to use the prod argument
### ios run_spm_post_script
```
fastlane ios run_spm_post_script
```
Runs the SPM post-build script.

Pass in a value for `prod` to use the prod argument
### ios tfprod
```
fastlane ios tfprod
```
Push production build to TestFlight from developer machine using testflight build numbers

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
