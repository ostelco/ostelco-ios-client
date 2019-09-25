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
    case instructions1
    case instructions2
    case instructions3
    case instructions4
    case instructions5
    
    var image: UIImage? {
        switch self {
        case .instructions1:
            return .ostelco_app
        case .instructions2:
            return .ostelco_screenshot1
        case .instructions3:
            return .ostelco_screenshot2
        case .instructions4:
            return .ostelco_screenshot3
        case .instructions5:
            return .ostelco_screenshot4
        }
    }
    
    var topText: BoldableText? {
        switch self {
        case .instructions1:
            return nil
        case .instructions2:
            return BoldableText(fullText: NSLocalizedString("When this screen appears: Tap 'Continue'\nand then 'Add Data Plan'", comment: "eSIM download instructions step 2."), boldedPortion: nil)
        case .instructions3:
            return BoldableText(fullText: NSLocalizedString("Tap 'Secondary'", comment: "eSIM download instructions step 3."), boldedPortion: nil)
        case .instructions4:
            return BoldableText(fullText: NSLocalizedString("Choose 'Custom Label' and name your\neSIM: OYA Malaysia", comment: "eSIM download instructions step 4."), boldedPortion: nil)
        case .instructions5:
            return BoldableText(fullText: NSLocalizedString("Choose \"...for mobile data only\"", comment: "eSIM download instructions step 5."), boldedPortion: nil)
        }
    }
    
    var bottomText: BoldableText? {
        switch self {
        case .instructions1:
            return BoldableText(
                fullText: NSLocalizedString("Before we set up your eSIM, please read\nthese instructions. We have also sent them\nto your email", comment: "eSim instructions bottom text step 1"),
                boldedPortion: nil)
        default:
            return nil
        }
    }
    
    var videoURL: URL? {
        switch self {
        default:
            return nil
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
