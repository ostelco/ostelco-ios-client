//
//  ScanICStepsViewController.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 4/29/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

protocol ScanICStepsDelegate: class {
    func finishedViewingNRICSteps()
}

class ScanICStepsViewController: UIViewController {
    
    weak var delegate: ScanICStepsDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @IBAction private func needHelpTapped() {
        self.showNeedHelpActionSheet()
    }
    
    @IBAction private func continueTapped() {
        self.delegate?.finishedViewingNRICSteps()
    }
}

extension ScanICStepsViewController: StoryboardLoadable {
    
    static var storyboard: Storyboard {
        return .ekyc
    }
    
    static var isInitialViewController: Bool {
        return false
    }
}
