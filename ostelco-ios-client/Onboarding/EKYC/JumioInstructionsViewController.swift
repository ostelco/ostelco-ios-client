//
//  JumioInstructionsViewController.swift
//  ostelco-ios-client
//
//  Created by Samuel Goodwin on 10/23/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

protocol JumioInstructionsDelegate: class {
    func jumioInstructionsViewed()
}

class JumioInstructionsViewController: UIViewController {
    weak var delegate: JumioInstructionsDelegate?
    
    @IBAction private func next() {
        delegate?.jumioInstructionsViewed()
    }
    
    @IBAction private func needHelpTapped() {
        showNeedHelpActionSheet()
    }
}

extension JumioInstructionsViewController: StoryboardLoadable {
    
    static var storyboard: Storyboard {
        return .ekyc
    }
    
    static var isInitialViewController: Bool {
        return false
    }
}
