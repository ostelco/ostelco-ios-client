//
//  CheckEmailViewController.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 5/7/19.
//  Copyright © 2019 mac. All rights reserved.
//

import OstelcoStyles
import UIKit

protocol CheckEmailDelegate: class {
    func resendLoginEmail()
}

class CheckEmailViewController: UIViewController {
    @IBOutlet private var gifView: LoopingVideoView!
    
    weak var delegate: CheckEmailDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gifView.videoURL = GifVideo.mail.url
        gifView.play()
    }
    
    @IBAction private func needHelpTapped() {
        showNeedHelpActionSheet()
    }
    
    @IBAction private func resendTapped() {
       delegate.resendLoginEmail()
    }
}

extension CheckEmailViewController: StoryboardLoadable {
    
    static var storyboard: Storyboard {
        return .email
    }
    
    static var isInitialViewController: Bool {
        return false
    }
}
