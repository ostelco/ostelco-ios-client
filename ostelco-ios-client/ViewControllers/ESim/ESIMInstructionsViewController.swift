//
//  ESIMInstructionsViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 5/22/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core
import OstelcoStyles
import UIKit
import AVKit

protocol ESIMInstructionsDelegate: class {
    func completedInstructions(_ controller: ESIMInstructionsViewController)
}

class ESIMInstructionsViewController: UIViewController {

    private var playerController: AVPlayerViewController!
    
    weak var delegate: ESIMInstructionsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.playerController.player = AVPlayer(url: ExternalLink.esimInstructionsVideo.url)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let playerController = segue.destination as? AVPlayerViewController {
            self.playerController = playerController
        }
    }
  
    @IBAction private func primaryButtonTapped(_ sender: UIButton) {
        self.delegate?.completedInstructions(self)
    }
}

extension ESIMInstructionsViewController: StoryboardLoadable {
    
    static var storyboard: Storyboard {
        return .esim
    }
    
    static var isInitialViewController: Bool {
        return false
    }
}
