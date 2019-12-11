//
//  SignUpCompletedViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 3/16/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

protocol SignUpCompletedDelegate: class {
    func acknowledgedSuccess()
    func regionName() -> String
}

class SignUpCompletedViewController: UIViewController {

    @IBOutlet private var gifView: LoopingVideoView!
    @IBOutlet private var statusLabel: UILabel!
    
    weak var delegate: SignUpCompletedDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gifView.videoURL = GifVideo.rocket.url(for: traitCollection.userInterfaceStyle)
        gifView.play()
        
        let format = NSLocalizedString("Oya is now active in %@", comment: "Message when user sees awesome.")
        statusLabel.text = String(format: format, delegate.regionName())
    }
    
    @IBAction private func continueTapped(_ sender: Any) {
        delegate.acknowledgedSuccess()
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
