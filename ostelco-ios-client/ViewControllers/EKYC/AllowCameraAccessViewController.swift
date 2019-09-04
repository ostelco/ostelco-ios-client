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
}

class AllowCameraAccessViewController: UIViewController {
    weak var delegate: AllowCameraAccessDelegate!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            delegate.cameraUsageAuthorized()
        } else {
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.delegate.cameraUsageAuthorized()
                } else {
                    self.showAlert(title: "Camera Access Not Allowed", msg: "Enable camera access in settings")
                }
            }
        }
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
