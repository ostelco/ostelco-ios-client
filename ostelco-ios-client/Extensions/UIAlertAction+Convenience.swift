//
//  UIAlertAction+Convenience.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 5/13/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

extension UIAlertAction {
    
    /// Basic "OK" action.
    ///
    /// - Parameter completion: [optional] The completion block to execute as the alert is dismissed. Defaults to nil.
    /// - Returns: The created action
    static func okAction(completion: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction(title: "OK",
                             style: .default,
                             handler: completion)
    }
    
    /// Basic "Cancel" style action
    ///
    /// - Parameters:
    ///   - title: The title of the action. Defaults to "Cancel"
    ///   - completion: [optional] The completion block to execute as the alert is dismissed. Defaults to nil.
    /// - Returns: The created action
    static func cancelAction(title: String = "Cancel", completion: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction(title: title,
                             style: .cancel,
                             handler: completion)
    }
    
    /// Basic "Destructive" style action
    ///
    /// - Parameters:
    ///   - title: The title of the action
    ///   - completion: [optional] The completion block to execute as the alert is dismissed.
    ///                 Note that no default value is provided here, since if the action is destructive you probably
    ///                 want to do *something*.
    /// - Returns: The created action.
    static func destructiveAction(title: String,
                                  completion: ((UIAlertAction) -> Void)?) -> UIAlertAction {
        return UIAlertAction(title: title,
                             style: .destructive,
                             handler: completion)
    }
}
