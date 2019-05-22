//
//  SignUpCompletedViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 3/16/19.
//  Copyright © 2019 mac. All rights reserved.
//

import OstelcoStyles
import UIKit

class SignUpCompletedViewController: UIViewController {

    @IBOutlet private var gifView: LoopingVideoView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let url = Bundle.main.url(forResource: "rocket", withExtension: "mp4", subdirectory: "gifMP4s") else {
            assertionFailure("Couldn't get URL for rocket gif!")
            return
        }
        
        self.gifView.videoURL = url
        self.gifView.play()
    }
    
    @IBAction private func continueTapped(_ sender: Any) {
        performSegue(withIdentifier: "home", sender: self)
    }
}
