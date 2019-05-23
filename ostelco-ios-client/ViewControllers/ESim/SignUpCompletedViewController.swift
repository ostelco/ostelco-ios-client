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
        
        self.gifView.videoURL = GifVideo.rocket.url
        self.gifView.play()
    }
    
    @IBAction private func continueTapped(_ sender: Any) {
        performSegue(withIdentifier: "home", sender: self)
    }
}
