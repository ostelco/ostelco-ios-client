//
//  OhNoViewController.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 4/25/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

/// A view controller for handling errors
class OhNoViewController: UIViewController {
    
    @IBOutlet private var primaryButton: UIButton!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: BodyTextLabel!
    @IBOutlet private var gifView: LoopingVideoView!
    @IBOutlet private var needHelpButton: UIButton!
    
    /// Convenience method for loading and populating with values for a given type
    ///
    /// - Parameter type: The type to use to configure copy and image
    /// - Returns: The instantiated and configured VC.
    static func fromStoryboard(type: OhNoIssueType) -> OhNoViewController {
        let vc = fromStoryboard()
        vc.type = type
        return vc
    }
    
    var type: OhNoIssueType = .noInternet
    
    /// The action to take when the user taps the primary button.
    var primaryButtonAction: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configurePrimaryButton()
        configureDescription()
        configureTitle()
        configureGIFVideo()
        
        needHelpButton.isHidden = type == .noInternet
    }
    
    private func configureDescription() {
        guard descriptionLabel != nil else {
            // Come back once the view has loaded.
            return
        }
        
        if let boldable = type.boldableText {
            descriptionLabel.setBoldableText(boldable)
        } else if let linkable = type.linkableText {
            descriptionLabel.setLinkableText(linkable)
        } else {
            descriptionLabel.text = "Something went wrong.\n\nTry again in a while, or contact support"
        }
    }
    
    private func configureTitle() {
        titleLabel?.text = type.displayTitle
    }
    
    private func configurePrimaryButton() {
        primaryButton.isHidden = primaryButtonAction == nil
        primaryButton.setTitle(type.buttonTitle, for: .normal)
    }
    
    private func configureGIFVideo() {
        gifView?.videoURL = type.gifVideo.url(for: traitCollection.userInterfaceStyle)
        gifView?.play()
    }
    
    @IBAction private func needHelpTapped() {
        showNeedHelpActionSheet()
    }
    
    @IBAction private func primaryButtonTapped() {
        guard let action = primaryButtonAction else {
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
            return NSLocalizedString("Oh no...", comment: "Generic error title")
        case .noInternet:
            return NSLocalizedString("No Internet Connection", comment: "Error title for no internet.")
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
                fullText: NSLocalizedString("Try again in a while", comment: "Error message when user has no connection"),
                linkedPortion: nil
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
        case .noInternet:
            return NSLocalizedString("Contact Support", comment: "Contact Support button title when no network.")
        case .serverUnreachable:
            return NSLocalizedString("Check again", comment: "Retry button title when server is unreachable.")
        case .paymentFailedGeneric,
             .paymentFailedCardDeclined:
            return NSLocalizedString("OK", comment: "Retry button title when payment fails.")
        }
    }
}
