# Bootstrap 

Make sure you have the latest version of the Xcode command line tools installed:
```
xcode-select --install
```
### carthage

- Install Carthage dependency manager `brew install carthage`
- Install dependencies `carthage bootstrap` or `carthage update` when adding new dependencies
- Install Apple Pay Payment Processing certificate with id `merchant.sg.redotter.alpha` (https://developer.apple.com/account/ios/certificate/)

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

### Deploy to Testflight (dev) locally
```
fastlane ios localbeta
```

### Deploy to Testflight (dev) from CI
To deploy using CI, push a tag to git matching pattern `beta-tf*`.
e.g.
```
 git tag -a beta-tf.v1.14 -m "Beta version 1 build 14"
 git push origin  beta-tf.v1.14
 ```

# Features
- [x] Can login with google using auth0
- [x] Shows login screen when opening app without a valid access token or refresh token
- [x] Shows home screen when opening app mith a valid access token
- [x] Shows home screen when opening app with invalid access token and valid refresh token
  - Test by setting the expiration time for access token to less than 60 seconds. Login to the app. Close the app completely. Start the 1 minute after expiration time.
- [x] Uses refresh token to get new access token and retries request if ostelco API returns 401
  - [x] Make sure data show in view is actually data from the repeated request and not from a cached state
- [x] Shows login screen if credentials are still invalid after trying to refresh the access token once after a 401 from ostelo API
- [x] Refresh access token if invalid when opening app from background
- [x] Logout button redirects user to login screen
- [x] Any action redirecting user to login screen also removes any cached data, like credentials from the app
- [ ] Balance
  - [x] Home screen shows correct balance left
  - [x] Balance updates every time user enters home screen
  - [x] Balance updates when user enters home screen while app was in background
  - ~~[ ] Balance updates automatically while user is on home screen~~
  - [ ] User can refresh balance on home screen
- [ ] User receives push notification when balance reaches low levels
  - TODO: Define flow, interaction and design
  - App should register for push notifications every time on home screen (assumed that user is logged in when entering home screen)
  - App should warn us if push notification registration fails
- [x] Home screen shows top up product with product label and price label
- [x] Top up product updates every time user enters the home screen
- [x] Top up product updates when user enters home screen while app was in background
- ~~[ ] Top up product updates automatically while user is on home screen~~
- [ ] Clicking on top up product opens apple pay dialog
  - Implemented, but needs to use correct stripe publishable key for production builds
  - All errors needs to be logged and sent to our server for immediate debugging
- [x] Home screen has two tabs, one for home screen and one for settings
- [ ] Settings screen shows links to the following:
  - [x] Personal details
  - [x] Terms & conditions
  - [x] Purchase history
  - [x] Log Out
  - [ ] Delete Account
- [x] Clicking on personal details shows the users profile information
- [x] Profile information should refresh every time user enters personal details
- ~~[ ] It should be possible to update email in personal details~~
- ~~[ ] It should be possible to update address in personal details~~
- ~~[ ] Updating any field in personal details should open a new screen with only an editable field for only the selected value~~
  - Should it save automatically
  - Should we have save button top right
  - Handle all error cases
- [x] Clicking on terms & conditions shows terms and conditions in an inapp webview
- [x] Clicking on purchase history shows list of all purchases
  - [x] Purchases should be ordered with latest first
  - [x] Refreshes purchases every time user enters purchase history
  - [x] Immediately refreshes with latest purchase after user performs top up in app
- [x] Clicking on log out logs user out and shows login screen
- [ ] Clicking on delete account asks user for ok / cancel confirmation before deleting users account and shows login screen
  - TODO: Missing API to perform action
- [ ] Registration processs with EKYC
  - TODO: Define flow, interaction and design
- [ ] User should be able to report problems / contact us through the app
 - TODO: Missing design


## Error handling
- Errors should be shown in a generic way
- Some errors that are more important to others should be handled in a custom way beneficial for the user
- All errors should be reported to us using some kind of bug / crash reporting tool
- User should be notified on errors, only if necessary, user should not need to manually refresh data, app can handle that for them, with a timer and a last fetched
- All errors should be handled in such a way that the user knows what to do next, if possible

- [ ] Handles all types of errors related to fetching of purchase history
- [ ] Handles all types of errors related to updating user profile
- [ ] Handles all types of errors related to fetching of user profile
- [ ] Handles all types of errors related to fetching top up product with a clear error message to user
  - User should see a clear error message explaining what went wrong, this should mostly be helpful for customer service if customer contacts
  - App should notify us that top up product failed to fetch
  - App handles case where it is unable to fetch top up product and does not have balance stored in local cache
  - App handles all errors thrown by API somehow
- [ ] Handles all types of errors related to fetching balance with a clear error message to user
  - If balance fails, user needs to be informed on when the last balance in the app was fetched
  - User should have a way to refresh the balance after it fails
  - User should see a clear error message explaining what went wrong, this should mostly be helpful for customer service if customer contacts
  - App should notify us that balance failed to fetch, since it's so important that the balance shows correct value at any time
  - App handles case where it is unable to fetch balance and does not have balance stored in local cache
  - App handles all errors thrown by API somehow 
- [ ] Handles all types of authentication errors with a clear error message to user

   
# Flows

## Authentication

- User opens app
  a. User is logged in and token is valid
    - set root view to TabBarController
  b. User is not logged in, token is invalid and refresh token is valid
    - set root view to TabBarController
  b. User is not logged in or token is invalid and refresh token is invalid
    - clear any local auth data
    - set root view to LoginViewController

- User logs in
  - open auth0 webview
    a. User logs in using google account
      a. User logs in successfully
        - Fetch access token and refresh token from auth0 credentials and store it using Auth0 Credentials Manager
	- Invalidate any cached state (could be a new user logging in)
        - set root view to TabBarController
      b. TODO: Define each error case that can happen and decide what do show the user on each individual case to give the user a good feedback on why the login process failed
    b. User cancels auth0 webview flow
      - auth0 webview closes automatically, do nothing else

- App receives 401 from API and tries to use refresh token to fetch a new access token
  a. Operation succeedes
    - Store new access token using Auth0 Credentials Manager
    - Repeat previous request
      a. Previous request completes
        - App continues as normal
      b. Previous request fails
        - set root view to LoginViewController
  b. Operation fails
    - set root view to LoginViewController
  c. refresh token is not defined
    - set root view to LoginViewController
  

## Refresh- and Access Token

### Access Token

Lasts for 7200 seconds = 2 hours before it has to be refreshed.
To set the expiration time:
1. login to auth0
2. navigate to APIs
3. select the *Google Endpoints API*
4. Set desired expiration time in seconds under *Token Expiration (Seconds)*
[Direct link to settings](https://manage.auth0.com/#/apis/5ab0deded0b22601d4668b39/settings)

### Refresh Token

Is valid until explicitly revoked throuh the auth0 dashboard.

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
- Payment: [Stripe - Apple Pay Integration](https://stripe.com/docs/mobile/ios/custom#apple-pay)
