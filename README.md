# Getting Started 
Make sure you have the latest version of the Xcode command line tools installed, which includes Ruby.

## Bundler 

[Bundler](https://bundler.io/docs.html) is a Ruby dependency manager we use to deal with versioning of several major iOS tools that are written in Ruby.

- Run `gem install bundler` anywhere on your system to install Bundler.
- Dependenices handled by Bundler are specified in the [`Gemfile`](Gemfile). Always specify a version to ensure you're using the same gems locally and on CI.
- From the root of this repository, run `bundle install` to install the **Fastlane** and **CocoaPods** versions we are currently using. 

## CocoaPods

[CocoaPods](https://guides.cocoapods.org/) is an iOS/Mac dependency manager written in Ruby. We use it to manage the third-party code we're using *within* the application. It will be installed when you run `bundle install` as described in the `Bundler` section. 

- Install dependencies by running `bundle exec pod install` from the root of the repo, or `bundle exec pod install --repo-update` when adding new dependencies. Adding the `bundle exec` prefix ensures you're using the version specified by Bundler.
- Make sure to specify versions of dependencies, otherwise CI may wind up with different versions than you have locally. 

## Fastlane

[Fastlane](https://docs.fastlane.tools/) is a suite of tools written in Ruby to make building, testing, and deploying your app much easier. It will be installed when you run `bundle install` as described in the `Bundler` section. 

- See [`fastlane/README.md`](fastlane/README.md) for a list of available lanes and what they do
- To run a lane, run `bundle exec fastlane [lane name]` at the command line.

Here are a few things we are handling with Fastlane:

### Certificates

- Install certificates &  profiles for developement:

    ```
    fastlane ios certificates
    ```

- Install deployment certificates, private key and profiles:

    ```
    fastlane match appstore --readonly
    ```

### Deploy to Testflight (dev) locally

```
fastlane ios tfbeta # Uses testflight build numbers.
```

### Deploy to Testflight (dev) from CI [Not tested]

To deploy using CI, push a tag to git matching pattern `beta-tf*`.
e.g.

```
git tag -a beta-tf.v1.14 -m "Beta version 1 build 14"
git push origin  beta-tf.v1.14
```


## Private Keys

Private keys are handled through a Swift Package Manager driven Xcode project at [`scripts/SPM/SPM.xcodeproj`](scripts/SPM/SPM.xcodeproj). A list of current commands is available in the [`README`](scripts/SPM/README.md) for that project. 

For local development, private keys are stored in files called `ios_secrets_dev.json` and `ios_secrets_prod.json` in a `.secrets` folder which is git-ignored. On CI, secrets are retrieved from the environment. 

The `SPM` script, depending on whether you pass the `-prod` option, will pipe the values in the appropriate JSON file as follows:

| `.plist` file | Contains Keys For | Is Configured By |
| --- | --- | --- |
| [`Auth0.plist`](ostelco-ios-client/SupportingFiles/Auth0.plist) | Keys related to Auth0 | [`Auth0Updater.swift`](scripts/SPM/Sources/Core/Secrets/Auth0Updater.swift) |
| [`GoogleService-Info.plist`](ostelco-ios-client/SupportingFiles/GoogleService-Info.plist) | Keys related to Firebase | [`FirebaseUpdater.swift`](scripts/SPM/Sources/Core/Secrets/FirebaseUpdater.swift) | 
| [`Environment.plist`](ostelco-ios-client/SupportingFiles/Environment.plist) | All other keys | [`EnvironmentUpdater.swift`](scripts/SPM/Sources/Core/Secrets/EnvironmentUpdater.swift) | 

Each `____Updater.swift` file contains a `CaseIterable enum` listing all keys for which values should be provided. 

Note that there are `jsonKey` and `plistKey` options in case the two keys are not identical. For example, all Firebase keys are prefixed with `FIR_` so as not to interfere with other potential environment variables. 

If you need to add a new key, you need to: 

- Update the dev and prod `json` files to contain the key, along with appropriate values for dev and prod
- Update the appropriate `plist` file to have the key and `SCRIPT_ME` as the value, both in the main app and in the [`TestRoot`](scripts/SPM/TestRoot) folder of the tests. 
- Commit these two `plist`s **BEFORE** you run your tests! Otherwise, the post-build script will reset the `plist` file.
- Update the appropriate `CaseIterable enum` in the  "is configured by" column.
- Update the environment variable in Circle CI.

At this point, tests in the `SPM` file should pass, as should all builds and tests on CI. 