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
    case instructions
    case scanQRCode
    case tapToContinue
    case forMobileDataOnly
    case watchVideo
    
    var image: UIImage? {
        switch self {
        case .instructions:
            return .ostelco_instructionsESimLaptop
        case .scanQRCode:
            return .ostelco_instructionsESimPhone
        case .tapToContinue:
            return .ostelco_instructionsESimContinue
        case .forMobileDataOnly:
            return .ostelco_instructionsESimUseSecondary
        case .watchVideo:
            return nil
        }
    }
    
    var topText: BoldableText {
        switch self {
        case .instructions:
            return BoldableText(
                fullText: NSLocalizedString("We are about to send you an email with a QR\ncode. Before we do that, please read these\ninstructions.", comment: "eSim download instructions. step 1"),
                boldedPortion: nil
            )
        case .scanQRCode:
            return BoldableText(
                fullText: NSLocalizedString("On your phone, go to:\nSettings - Mobile Data - Add Data Plan", comment: "eSim download instructions. step 2"),
                boldedPortion: NSLocalizedString("Settings - Mobile Data - Add Data Plan", comment: "eSim download instructions. step 2 (downloaded part)")
            )
        case .tapToContinue:
            return BoldableText(
                fullText: NSLocalizedString("Then tap continue...", comment: "eSim download instructions. step 3"),
                boldedPortion: nil
            )
        case .forMobileDataOnly:
            return BoldableText(
                fullText: NSLocalizedString("Choose \"...for mobile data only\"", comment: "eSim download instructions. step 4"),
                boldedPortion: nil
            )
        case .watchVideo:
            return BoldableText(
                fullText: NSLocalizedString("Still unsure? Watch this video!", comment: "eSim download instructions. step 5"),
                boldedPortion: nil
            )
        }
    }
    
    var bottomText: BoldableText? {
        switch self {
        case .instructions:
            return BoldableText(
                fullText: NSLocalizedString("Open the email on\nanother device", comment: "eSim instructions bottom text step 1"),
                boldedPortion: NSLocalizedString("another device", comment: "eSim instructions bottom text step 1 (boldable part)")
            )
        case .scanQRCode:
            return BoldableText(
                fullText: NSLocalizedString("Scan the QR code", comment: "eSim instructions bottom text step 2"),
                boldedPortion: nil
            )
        case .tapToContinue:
            return nil
        case .forMobileDataOnly:
            return nil
        case .watchVideo:
            return nil
        }
    }
    
    var videoURL: URL? {
        switch self {
        case .watchVideo:
            return ExternalLink.esimInstructionsVideo.url
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
        
        self.topTextLabel.setBoldableText(self.esimPage.topText)
        
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
