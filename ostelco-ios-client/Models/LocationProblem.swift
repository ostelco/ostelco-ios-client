//
//  LocationProblem.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 4/24/19.
//  Copyright © 2019 mac. All rights reserved.
//

import CoreLocation
import UIKit

/// Backing type for showing multiple different types of location problem
///
/// - disabledInSettings: The user has disabled location access in settings.
/// - deniedByUser: When we asked, the user declined notification permissions.
/// - restrictedByParentalControls: The user's location has been
/// - notDetermined: We don't know what the user wants. Theoretically we should only get this if the user hasn't been
///                  prompted yet,
/// - authorizedButWrongCountry: The user has allowed notification access, but they are not in the correct country.
enum LocationProblem {
    case disabledInSettings
    case deniedByUser
    case restrictedByParentalControls
    case notDetermined
    case authorizedButWrongCountry(expected: String, actual: String)
    
    /// The image to use to illustrate the problem.
    var image: UIImage {
        // This will be addressed via codegen later
        switch self {
        case .disabledInSettings,
             .notDetermined:
            return UIImage(named: "instructionsLocation")!
        case .deniedByUser,
             .restrictedByParentalControls,
             .authorizedButWrongCountry:
            return UIImage(named: "illustrationLocation")!
        }
    }
    
    /// The title of the screen showing the problem
    var title: String {
        switch self {
        case .authorizedButWrongCountry:
            return "Wrong country selected?"
        case .deniedByUser,
             .disabledInSettings,
             .notDetermined,
             .restrictedByParentalControls:
            return "Allow location access"
        }
    }
    
    /// The explanatory copy the user should see about the problem.
    var copy: String {
        switch self {
        case .authorizedButWrongCountry(let expected, let actual):
            return """
            It seems like you're in \(actual).
            
            To give you mobile data, by law, we have to verify that you're in \(expected)
            """
        case .disabledInSettings,
             .deniedByUser,
             .notDetermined:
            return """
            To give you mobile data, by law, we have to verify which country you're in.
            
            Please enable "Location Services" in Settings.
            """
        case .restrictedByParentalControls:
            return """
            To give you mobile data, by law, we have to verify which country you're in.
            
            "Location Services" are disabled due to Parental Control Settings on this device.
            """
        }
    }
    
    /// [optional] The primary button title. If no title is returned, the button should be hidden.
    var primaryButtonTitle: String? {
        switch self {
        case .disabledInSettings,
             .deniedByUser,
             .notDetermined:
            return "Settings"
        case .authorizedButWrongCountry:
            return "Retry"
        case .restrictedByParentalControls:
            return nil
        }
    }
}
