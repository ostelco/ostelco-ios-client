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
        switch self {
        case .disabledInSettings,
             .notDetermined:
            return .ostelco_instructionsLocation
        case .deniedByUser,
             .restrictedByParentalControls,
             .authorizedButWrongCountry:
            return nil
        }
    }
    
    /// The URL of the gif video to show. If nil, there is no gif video.
    func videoURL(for appearance: UIUserInterfaceStyle) -> URL? {
        switch self {
        case .disabledInSettings,
             .notDetermined:
            return nil
        case .deniedByUser,
             .restrictedByParentalControls,
             .authorizedButWrongCountry:
            return GifVideo.location.url(for: appearance)
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
        let link = Link(NSLocalizedString("by law", comment: "Location errors: linkable part"), url: ExternalLink.locationRequirement.url)
        
        switch self {
        case .authorizedButWrongCountry(let expected, let actual):
            let format = "It seems like you're in %@.\n\nTo give you mobile data, by law, we have to verify that you're in %@"
            return LinkableText(
                fullText: String(format: NSLocalizedString(format, comment: "Error message when user is in the wrong country"), expected, actual),
                linkedPortion: link
            )!
        case .disabledInSettings, .deniedByUser, .notDetermined:
            return LinkableText(
                fullText: NSLocalizedString("To give you mobile data, by law, we have to verify which country you're in.\n\nPlease grant OYA \"Location Access\" in your phone's Settings.", comment: "Error when user has disabled location access."),
                linkedPortion: link
            )!
        case .restrictedByParentalControls:
            return LinkableText(
                fullText: NSLocalizedString("To give you mobile data, by law, we have to verify which country you're in.\n\n\"Location Services\" are disabled due to Parental Control Settings on this phone.", comment: "Error when user is restricted by parental controls"),
                linkedPortion: link
            )!
        }
    }
    
    /// The primary button title. If no title is returned, the button should be hidden.
    var primaryButtonTitle: String? {
        switch self {
        case .disabledInSettings,
             .deniedByUser:
            return NSLocalizedString("Go to Settings", comment: "Title for primary action button when user needs to fix location settings")
        case .notDetermined,
             .authorizedButWrongCountry:
            return NSLocalizedString("Retry", comment: "Title for primary action button when user needs to retry selecting a country")
        case .restrictedByParentalControls:
            return nil
        }
    }
}
