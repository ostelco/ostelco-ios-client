//
//  OhNoViewController.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 4/25/19.
//  Copyright © 2019 mac. All rights reserved.
//

import OstelcoStyles
import UIKit
import ostelco_core

/// A view controller for handling errors
class OhNoViewController: UIViewController {
    
    @IBOutlet private var primaryButton: UIButton!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: BodyTextLabel!
    @IBOutlet private var gifView: LoopingVideoView!
    
    /// Convenience method for loading and populating with values for a given type
    ///
    /// - Parameter type: The type to use to configure copy and image
    /// - Returns: The instantiated and configured VC.
    static func fromStoryboard(type: OhNoIssueType) -> OhNoViewController {
        let vc = self.fromStoryboard()
        vc.displayTitle = type.displayTitle
        vc.videoURL = type.gifVideo.url(for: vc.traitCollection.userInterfaceStyle)
        vc.buttonTitle = type.buttonTitle
        vc.boldableText = type.boldableText
        vc.linkableText = type.linkableText
        
        return vc
    }
    
    /// The title at the top of the screen
    var displayTitle: String = "Oh no" {
        didSet {
            self.configureTitle()
        }
    }
    
    /// The text displayed on the button
    var buttonTitle: String = "Try again" {
        didSet {
            self.configurePrimaryButton()
        }
    }
    
    /// [optional] Text which may or may not contain bolding. Note that either boldable or linkable text should be provided.
    var boldableText: BoldableText? {
        didSet {
            self.configureDescription()
        }
    }
    
    /// [optional] Text containing a link. Note that either boldable or linkable text should be provided.
    var linkableText: LinkableText? {
        didSet {
            self.configureDescription()
        }
    }
    
    /// The gif video to use to entertain the user while explaining something went wrong.
    var videoURL: URL? {
        didSet {
            self.configureGIFVideo()
        }
    }
    
    /// The action to take when the user taps the primary button.
    var primaryButtonAction: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configurePrimaryButton()
        self.configureDescription()
        self.configureTitle()
        self.configureGIFVideo()
    }
    
    private func configureDescription() {
        guard self.descriptionLabel != nil else {
            // Come back once the view has loaded.
            return
        }
        
        if let boldable = self.boldableText {
            self.descriptionLabel.setBoldableText(boldable)
        } else if let linkable = self.linkableText {
            self.descriptionLabel.setLinkableText(linkable)
        } else {
            self.descriptionLabel.text = "Something went wrong.\n\nTry again in a while, or contact support"
        }
    }
    
    private func configureTitle() {
        self.titleLabel?.text = self.displayTitle
    }
    
    private func configurePrimaryButton() {
        primaryButton?.isHidden = primaryButtonAction == nil
        primaryButton?.setTitle(self.buttonTitle, for: .normal)
    }
    
    private func configureGIFVideo() {
        self.gifView?.videoURL = self.videoURL
        self.gifView?.play()
    }
    
    @IBAction private func needHelpTapped() {
        self.showNeedHelpActionSheet()
    }
    
    @IBAction private func primaryButtonTapped() {
        guard let action = self.primaryButtonAction else {
            ApplicationErrors.assertAndLog("You probably want to do something here!")
            return
        }
        
        action()
    }
}

extension OhNoViewController: StoryboardLoadable {
    
    static var isInitialViewController: Bool {
        return true
    }
    
    static var storyboard: Storyboard {
        return .ohNo
    }
}

extension OhNoIssueType {
    var displayTitle: String {
        switch self {
        case .ekycRejected:
            return NSLocalizedString("EKYC Rejected", comment: "Error title when eKYC is rejected")
        case .generic:
            return NSLocalizedString("Oh no", comment: "Generic error title")
        case .noInternet:
            return NSLocalizedString("No internet connection", comment: "Error title for no internet.")
        case .paymentFailedGeneric:
            return NSLocalizedString("Payment Failed", comment: "Error title when payment failed.")
        case .paymentFailedCardDeclined:
            return NSLocalizedString("Card Declined", comment: "Error title when card is declined.")
        case .serverUnreachable:
            return NSLocalizedString("Server Unreachable", comment: "Error title when server is unreachable.")
        }
    }
    
    var gifVideo: GifVideo {
        switch self {
        case .generic:
            return .taken
        case .ekycRejected:
            return .blank_canvas
        case .noInternet, .paymentFailedGeneric, .paymentFailedCardDeclined, .serverUnreachable:
            return .no_connection
        }
    }
    
    var linkableText: LinkableText? {
        if case .noInternet = self {
            return LinkableText(
                fullText: NSLocalizedString("Try again in a while or contact support\n\nsupport@oya.world", comment: "Error message when user has no connection"),
                linkedPortion: Link(
                    NSLocalizedString("support@oya.world", comment: "Error message when user has no connection: linkable part"),
                    url: URL(string: "mailto:support@oya.world")!
                )
            )
        }
        return nil
    }
    
    var boldableText: BoldableText? {
        switch self {
        case .noInternet:
            return nil
        case .generic(let code):
            guard let errorCode = code else {
                return BoldableText(fullText: NSLocalizedString("Something went wrong. Try again in a while.", comment: "Error explanation for generic errors."),
                                    boldedPortion: nil)
            }
            let format = NSLocalizedString("Something went wrong. Try again in a while. If you contact customer support, please use this error code: %@", comment: "Generic error explanation.")
            return BoldableText(fullText: String(format: format, errorCode), boldedPortion: errorCode)
        case .ekycRejected:
            return BoldableText(fullText: NSLocalizedString("Something went wrong.\n\nTry again in a while, or contact support", comment: "Error explanation when eKYC is rejected."),
                                boldedPortion: nil)
        case .paymentFailedGeneric:
            return BoldableText(fullText: NSLocalizedString("Something went wrong in our system. We have not taken any money from your account. Try again in a while or contact customer support.", comment: "Generic error explanation when payment fails."),
                                boldedPortion: nil)
        case .paymentFailedCardDeclined:
            return BoldableText(fullText: NSLocalizedString("Your card was declined. Contact your bank or try with another card.", comment: "Error explanation when credit card is declined."),
                                boldedPortion: nil)
        case .serverUnreachable:
            return BoldableText(fullText: NSLocalizedString("We were not able to reach our servers. Please try again later.", comment: "Error explanation when server is unreachable."),
                                boldedPortion: nil)
        }
    }
    
    var buttonTitle: String {
        switch self {
        case .generic:
            return NSLocalizedString("Try again", comment: "Retry button title when MyInfo fails.")
        case .ekycRejected:
            return NSLocalizedString("Retry", comment: "Retry button title when eKYC is rejected.")
        case .noInternet, .serverUnreachable:
            return NSLocalizedString("Check again", comment: "Retry button title when server is unreachable or no network.")
        case .paymentFailedGeneric,
             .paymentFailedCardDeclined:
            return NSLocalizedString("OK", comment: "Retry button title when payment fails.")
        }
    }
}
