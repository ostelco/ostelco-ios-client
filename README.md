# Dependencies

- Install Carthage dependency manager `brew install carthage`
- Install dependencies `carthage bootstrap` (I think that's the rigth command)

# Flows

## Authentication

- User opens app
  a. User is logged in and token is valid
    - set root view to TabBarController
  b. User is not logged in or token is invalid
    - clear any local auth data
    - set root view to LoginViewController

- User logs in
  - open auth0 webview
    a. User logs in using google account
      a. User logs in successfully
        - Fetch access token from auth0 credentials and store it in A0SimpleKeychain
        - Set login status to true using UserDefaults
        - set root view to TabBarController
      b. TODO: Define each error case that can happen and decide what do show the user on each individual case to give the user a good feedback on why the login process failed
    b. User cancels auth0 webview flow
      - auth0 webview closes automatically, do nothing else
# TODO:
- Decide on how to handle state management
  - (Apollo Graphql)[https://www.apollographql.com/docs/ios/]
  - (Siesta)[https://bustoutsolutions.github.io/siesta/]
- How to structure files
- Describe how to do logging and activity tracing for logging in async workloads
- Decide on crash reporting tool

# Crash Reporting Tool

## Requirements for crash reporting tool
- capture crashes
- capture install errors
- bug reporting in app with one or more of the following:
  - screenshot
  - replay screens up until crash
  - possible to draw on screenshot to highlight something
  - send text with the bug report
  - send device logs with bug report
- send device logs with crash
- possible to communicate back with user in app or other means
- integrates with other customer service portals (zendesk, freshdesk, ++)
- pricing?
- integrates with ios and android?
  - doesn't need to work on all platforms if we integrate with customer service portal
- abilitiy to manually send errors
- MOST IMPORTANT enough information when:
  - crash occurs
  - user reports bug
- shake to open and manually open
- configurable in app ui for bug reporting etc
- in app onboarding screens to tell users about the tool

## [Buddybuild](https://docs.buddybuild.com/)
## [Bugsee](https://www.bugsee.com/)
## [Instabug](https://instabug.com/)
## [Sentry](https://sentry.io/welcome/)

# Resources

- Choosing dependency manager: [Carthage or Cocoapods: That is the question](https://medium.com/xcblog/carthage-or-cocoapods-that-is-the-question-1074edaafbcb)
- Simple login insipration: [Swift Login / Logout Navigation Process](https://medium.com/@paul.allies/ios-swift4-login-logout-branching-4cdbc1f51e2c)
- Auth0 login setup: [IOS Swift: User Sessions] (https://auth0.com/docs/quickstart/native/ios-swift/03-user-sessions)
- Auth0 browser vs native flow pro con: [Browser-Based vs. Native Login Flows on Mobile Device](https://auth0.com/docs/design/browser-based-vs-native-experience-on-mobile)
- Logging is Swift: 
  - [Unified Logging and Activity Tracing](https://medium.com/@abjurato/unified-logging-and-activity-tracing-aa77ffe9fb53)
  - [Migrating to Unified Logging, Swift Edition](https://www.bignerdranch.com/blog/migrating-to-unified-logging-swift-edition/)
- Crash Reporting Tools:
  - [Best iOS crash reporting tool)[https://www.crashprobe.com/ios/]
- REST API clients:
  - [Siesta](https://bustoutsolutions.github.io/siesta/)
