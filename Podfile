# The minimum supported iOS version for your project
platform :ios, '12.1'

# Enable everything to be compiled into frameworks
use_frameworks!

# Don't show warnings from frameworks to prevent polluting warnings
inhibit_all_warnings!


abstract_target 'ostelco-ios' do
  pod 'Auth0', '~> 1.14.2'
  pod 'Crashlytics', '~> 3.12.0'
  pod 'Fabric', '~> 1.9.0'
  pod 'FreshchatSDK', '~> 2.4.3'
  pod 'Firebase/Core', '~>5.20.1'
  pod 'Firebase/DynamicLinks', '~>5.20.1'
  pod 'Firebase/Messaging', '~>5.20.1'
  pod 'JumioMobileSDK/Netverify', '~> 2.15.0'
  pod 'JWTDecode', '~> 2.2'
  pod 'PromiseKit', '~> 6.8.4'
  pod 'RxCoreLocation', '~> 1.3.1'
  pod 'RxSwift', '~> 4.5.0'
  pod 'Siesta', '~> 1.0'
  pod 'Siesta/UI', '~> 1.0'
  pod 'SimpleKeychain', '~> 0.8.1'
  pod 'Stripe', '~> 14.0.0'
  pod 'SwiftyJSON', '~> 4.3.0'


  # Dev app target
  target 'Oya development app' do
    
    # Test target
    target 'dev-ostelco-ios-clientTests' do
      inherit! :search_paths
    end
  end
  
  # Prod app target
  target 'Oya app' do
  end
end
