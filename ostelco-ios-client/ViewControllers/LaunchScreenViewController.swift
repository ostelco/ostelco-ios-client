//
//  LaunchScreenViewController.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 4/8/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class LaunchScreenViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        if let bundleIndentifier = Bundle.main.bundleIdentifier {
            if bundleIndentifier.contains("dev") {
                self.imageView.image = UIImage(named: "StoryboardLaunchScreenDevelopment")!
            } else {
                self.imageView.image = UIImage(named: "StoryboardLaunchScreenProduction")!
            }
        } else {
            self.imageView.image = UIImage(named: "StoryboardLaunchScreenDevelopment")!
        }
    }
}

