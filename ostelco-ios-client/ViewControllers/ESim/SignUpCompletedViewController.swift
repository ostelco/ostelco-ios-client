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
    func acknowledgedSuccess(profile: SimProfile)
}

class SignUpCompletedViewController: UIViewController {

    @IBOutlet private var gifView: LoopingVideoView!
    
    weak var delegate: SignUpCompletedDelegate?
    
    var profile: SimProfile?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gifView.videoURL = GifVideo.rocket.url
        self.gifView.play()
    }
    
    @IBAction private func continueTapped(_ sender: Any) {
        guard let profile = self.profile else {
            ApplicationErrors.assertAndLog("No profile when trying to acknowledge success?!")
            return
        }
        
        self.delegate?.acknowledgedSuccess(profile: profile)
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
