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
public enum LocationProblem {
    case disabledInSettings
    case deniedByUser
    case restrictedByParentalControls
    case notDetermined
    case authorizedButWrongCountry(expected: String, actual: String)
}
