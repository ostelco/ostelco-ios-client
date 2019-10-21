//
//  ESIMPageViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 5/22/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core
import OstelcoStyles
import UIKit
import AVKit

enum ESIMPage: Int, CaseIterable {
    case video
    
    var image: UIImage? {
        switch self {
        case .video:
            return nil
        }
    }
    
    var topText: BoldableText? {
        switch self {
        case .video:
            return nil
        }
    }
    
    var bottomText: BoldableText? {
        switch self {
        default:
            return nil
        }
    }
    
    var videoURL: URL? {
        switch self {
        case .video:
            return ExternalLink.esimInstructionsVideo.url
        }
    }
    
    var viewController: ESIMPageViewController {
        return ESIMPageViewController.fromStoryboard(with: self)
    }
}

class ESIMPageViewController: UIViewController {

    @IBOutlet private var topTextLabel: BodyTextLabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var bottomTextLabel: BodyTextLabel!
    @IBOutlet private var playerView: UIView!
    
    // This is set up in the convenience constructor
    private(set) var esimPage: ESIMPage!
    
    /// Has to be set up through `prepareForSegue` when this VC is loaded
    private var playerController: AVPlayerViewController!
    
    /// Convenience constructor
    ///
    /// - Parameter page: The page you wish to display.
    static func fromStoryboard(with page: ESIMPage) -> ESIMPageViewController {
        let vc = self.fromStoryboard()
        vc.esimPage = page

        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let topText = self.esimPage.topText {
            self.topTextLabel.setBoldableText(topText)
        } else {
            self.topTextLabel.isHidden = true
        }

        if let bottomText = self.esimPage.bottomText {
            self.bottomTextLabel.setBoldableText(bottomText)
        } else {
            self.bottomTextLabel.isHidden = true
        }
        
        if let image = self.esimPage.image {
            self.imageView.image = image
        } else {
            self.imageView.isHidden = true
        }
        
        if let videoURL = self.esimPage.videoURL {
            self.playerController.player = AVPlayer(url: videoURL)
        } else {
            self.playerView.isHidden = true
        }
        
        self.playerController.view.backgroundColor = OstelcoColor.background.toUIColor
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let playerController = segue.destination as? AVPlayerViewController {
            self.playerController = playerController
        }
    }
}

extension ESIMPageViewController: StoryboardLoadable {
    static var storyboard: Storyboard {
        return .esim
    }
    
    static var isInitialViewController: Bool {
        return false
    }
}
