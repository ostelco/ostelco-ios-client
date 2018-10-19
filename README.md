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
  - (RxSwift)[https://github.com/ReactiveX/RxSwift]
  - (Apollo Graphql)[https://www.apollographql.com/docs/ios/]
- How to structure files


# Resources

- Choosing dependency manager: [Carthage or Cocoapods: That is the question](https://medium.com/xcblog/carthage-or-cocoapods-that-is-the-question-1074edaafbcb)
- Simple login insipration: [Swift Login / Logout Navigation Process](https://medium.com/@paul.allies/ios-swift4-login-logout-branching-4cdbc1f51e2c)
- Auth0 login setup: [IOS Swift: Login] (https://auth0.com/docs/quickstart/native/ios-swift/00-login)
- Auth0 browser vs native flow pro con: [Browser-Based vs. Native Login Flows on Mobile Device](https://auth0.com/docs/design/browser-based-vs-native-experience-on-mobile)
