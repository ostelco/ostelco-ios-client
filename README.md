# Bootstrap 
Make sure you have the latest version of the Xcode command line tools installed:

### Cocoapods

- Install `cocoapods` dependency manager `sudo gem install cocoapods`
- Install dependencies `pod install` or `pod install --repo-update` when adding new dependencies

### fastlane
- Install _fastlane_ using
```
brew cask install fastlane
```
or alternatively using `sudo gem install fastlane -NV`

### Certificates
- Install certificates &  profiles for developement
```
fastlane ios certificates
```
- Install deployment certificates, private key and profiles
```
fastlane match appstore --readonly
```

### Private Keys
- JUMIO Credentials are now stored in `debug_overrides.xcconfig` and `release_overrides.xcconfig` in
  `ostelco-ios-client/ostelco-ios-client/src/environments` folder. These files are not part of the
  github repo. Use the following schema to create these files. The values are to be downloaded
  from the JUMIO dashboard.
  ```
  // Configuration settings file format documentation can be found at:
  // https://help.apple.com/xcode/#/dev745c5c974
  jumio_token = <abcd>
  jumio_secret = <efgh>
  ```

### Deploy to Testflight (dev) locally
```
fastlane ios tfbeta # Uses  testflight build numbers.
```

### Deploy to Testflight (dev) from CI [Not tested]
To deploy using CI, push a tag to git matching pattern `beta-tf*`.
e.g.
```
 git tag -a beta-tf.v1.14 -m "Beta version 1 build 14"
 git push origin  beta-tf.v1.14
 ```

