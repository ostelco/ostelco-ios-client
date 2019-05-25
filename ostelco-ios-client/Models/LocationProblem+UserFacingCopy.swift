//
//  LocationProblem+UserFacingCopy.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 4/25/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core
import OstelcoStyles
import UIKit

extension LocationProblem {
    
    /// The image to use to illustrate the problem.
    var image: UIImage? {
        // This will be addressed via codegen later
        switch self {
        case .disabledInSettings,
             .notDetermined:
            return UIImage(named: "instructionsLocation")!
        case .deniedByUser,
             .restrictedByParentalControls,
             .authorizedButWrongCountry:
            return nil
        }
    }
    
    /// The URL of the gif video to show. If nil, there is no gif video.
    var videoURL: URL? {
        switch self {
        case .disabledInSettings,
             .notDetermined:
            return nil
        case .deniedByUser,
             .restrictedByParentalControls,
             .authorizedButWrongCountry:
            return GifVideo.location.url
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
    var linkableCopy: LinkableText {
        switch self {
        case .authorizedButWrongCountry(let expected, let actual):
            return LinkableText(fullText: """
            It seems like you're in \(actual).
            
            To give you mobile data, by law, we have to verify that you're in \(expected)
            """, linkedPortion: "by law")!
        case .disabledInSettings,
             .deniedByUser,
             .notDetermined:
            return LinkableText(fullText: """
            To give you mobile data, by law, we have to verify which country you're in.
            
            Please enable "Location Services" in Settings.
            """, linkedPortion: "by law")!
        case .restrictedByParentalControls:
            return LinkableText(fullText: """
            To give you mobile data, by law, we have to verify which country you're in.
            
            "Location Services" are disabled due to Parental Control Settings on this device.
            """, linkedPortion: "by law")!
        }
    }
    
    /// [optional] The primary button title. If no title is returned, the button should be hidden.
    var primaryButtonTitle: String? {
        switch self {
        case .disabledInSettings,
             .deniedByUser:
            return "Settings"
        case .notDetermined,
             .authorizedButWrongCountry:
            return "Retry"
        case .restrictedByParentalControls:
            return nil
        }
    }
}
