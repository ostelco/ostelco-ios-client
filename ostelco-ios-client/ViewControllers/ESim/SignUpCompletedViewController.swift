//
//  SignUpCompletedViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 3/16/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core
import OstelcoStyles
import UIKit

protocol SignUpCompletedDelegate: class {
    func acknowledgedSuccess()
}

class SignUpCompletedViewController: UIViewController {

    @IBOutlet private var gifView: LoopingVideoView!
    
    weak var delegate: SignUpCompletedDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gifView.videoURL = GifVideo.rocket.url
        gifView.play()
        
        OstelcoAnalytics.logEvent(.SignUpCompleted)
    }
    
    @IBAction private func continueTapped(_ sender: Any) {
        delegate?.acknowledgedSuccess()
    }
}

extension SignUpCompletedViewController: StoryboardLoadable {
    
    static var storyboard: Storyboard {
        return .esim
    }
    
    static var isInitialViewController: Bool {
        return false
    }
    
}
