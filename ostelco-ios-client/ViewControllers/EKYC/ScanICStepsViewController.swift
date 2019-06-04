//
//  ScanICStepsViewController.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 4/29/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class ScanICStepsViewController: UIViewController {
    
    // TODO: Rip this out when we use nav controllers
    @IBAction private func backTapped() {
        self.dismiss(animated: true)
    }
    
    @IBAction private func needHelpTapped() {
        self.showNeedHelpActionSheet()
    }

extension ScanICStepsViewController: StoryboardLoadable {
    
    static var storyboard: Storyboard {
        return .ekyc
    }
    
    static var isInitialViewController: Bool {
        return false
    }
}
