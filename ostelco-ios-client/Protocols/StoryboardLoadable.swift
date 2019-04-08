//
//  StoryboardLoadable.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 4/8/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

/// A protocol which can only be applied to UIViewControllers to make
/// loading from storyboards less stringly typed.
protocol StoryboardLoadable: UIViewController {
    
    /// What storyboard does this VC live in?
    static var storyboard: Storyboard { get }
    
    /// Is this the intial view controller of the storyboard where this is hosted?
    static var isInitialViewController: Bool { get }
    
    /// What is the identifier in the storyboard for this VC?
    static var identifier: String { get }
}

extension StoryboardLoadable {
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static func fromStoryboard() -> Self {
        if self.isInitialViewController {
            return self.storyboard.initialViewController()
        } else {
            return self.storyboard.viewController(with: self.identifier)
        }
    }
}
