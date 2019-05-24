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
            return UIImage(named: "instructionsESimLaptop")
        case .scanQRCode:
            return UIImage(named: "instructionsESimPhone")
        case .tapToContinue:
            return UIImage(named: "instructionsESimContinue")
        case .forMobileDataOnly:
            return UIImage(named: "instructionsESimUseSecondary")
        case .watchVideo:
            return nil
        }
    }
    
    var topText: [String] {
        switch self {
        case .instructions:
            return ["""
            We are about to send you an email with a QR
            code. Before we do that, please read these
            instructions.
            """]
        case .scanQRCode:
            return ["""
            On your phone, go to:
            Settings - Mobile Data - Add Data Plan
            """, "Settings - Mobile Data - Add Data Plan"]
        case .tapToContinue:
            return ["""
            Then tap continue...
            """]
        case .forMobileDataOnly:
            return ["""
            Choose "...for mobile data only"
            """]
        case .watchVideo:
            return ["""
            Still unsure? Watch this video!
            """]
        }
    }
    
    var bottomText: [String]? {
        switch self {
        case .instructions:
            return ["""
            Open the email on
            another device
            """, "another device"]
        case .scanQRCode:
            return ["""
            Scan the QR code
            """]
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
    // swiftlint:disable:next implicitly_unwrapped_optional
    private(set) var esimPage: ESIMPage!
    
    /// Has to be set up through `prepareForSegue` when this VC is loaded
    // swiftlint:disable:next implicitly_unwrapped_optional
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
        
        setTextLabel(topTextLabel, esimPage.topText)
        
        if let bottomText = esimPage.bottomText {
            setTextLabel(bottomTextLabel, bottomText)
        } else {
            bottomTextLabel.isHidden = true
        }
        
        if let image = esimPage.image {
            imageView.image = image
        } else {
            imageView.isHidden = true
        }
        
        if let videoURL = esimPage.videoURL {
            playerController.player = AVPlayer(url: videoURL)
        } else {
            playerView.isHidden = true
        }
    }
    
    private func setTextLabel(_ label: BodyTextLabel, _ parts: [String]) {
        switch parts.count {
        case 1:
            label.text = parts[0]
        case 2:
            label.setFullText(parts[0], withBoldedPortion: parts[1])
        default:
            break
        }
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
