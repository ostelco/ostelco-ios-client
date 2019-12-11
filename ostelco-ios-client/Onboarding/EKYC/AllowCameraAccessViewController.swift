//
//  AllowCameraAccessViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 9/3/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import AVFoundation

protocol AllowCameraAccessDelegate: class {
    func cameraUsageAuthorized()
    func chooseAnotherMethod()
}

class AllowCameraAccessViewController: UIViewController {
    
    @IBOutlet private var gifView: LoopingVideoView!
    
    weak var delegate: AllowCameraAccessDelegate!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gifView.videoURL = GifVideo.selfie.url(for: traitCollection.userInterfaceStyle)
        gifView.play()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            delegate.cameraUsageAuthorized()
        }
    }
    
    // MARK: - IBActions
    
    @IBAction private func chooseAnotherMethodTapped(_ sender: Any) {
        delegate.chooseAnotherMethod()
    }
    
    @IBAction private func needHelpTapped(_ sender: Any) {
        showNeedHelpActionSheet()
    }
    
    @IBAction private func settingsTapped(_ sender: Any) {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            fatalError("Could not construct settings URL!")
        }
        UIApplication.shared.open(settingsURL)
    }
}

extension AllowCameraAccessViewController: StoryboardLoadable {
    
    static var storyboard: Storyboard {
        return .ekyc
    }
    
    static var isInitialViewController: Bool {
        return false
    }
}
