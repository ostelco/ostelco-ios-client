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
        vc.videoURL = type.gifVideo.url
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
            return "EKYC Rejected"
        case .generic, .myInfoFailed:
            return "Oh no"
        case .noInternet:
            return "No internet connection"
        case .paymentFailedGeneric:
            return "Payment Failed"
        case .paymentFailedCardDeclined:
            return "Card Declined"
        }
    }
    
    var gifVideo: GifVideo {
        switch self {
        case .generic,
             .myInfoFailed:
            return .taken
        case .ekycRejected:
            return .blank_canvas
        case .noInternet, .paymentFailedGeneric, .paymentFailedCardDeclined:
            return .no_connection
        }
    }
    
    var linkableText: LinkableText? {
        if case .noInternet = self {
            return LinkableText(fullText: """
Try again in a while or contact support

support@oya.world
""",
                                linkedBits: ["support@oya.world"])
        }
        return nil
    }
    
    var boldableText: BoldableText? {
        switch self {
        case .noInternet:
            return nil
        case .generic(let code):
            guard let errorCode = code else {
                return BoldableText(fullText: "Something went wrong. Try again in a while.",
                                    boldedPortion: nil)
            }
            
            return BoldableText(fullText:
                "Something went wrong. Try again in a while. If you contact customer support, please use this error code: \(errorCode)", boldedPortion: "\(errorCode)")
        case .ekycRejected:
            return BoldableText(fullText: "Something went wrong.\n\nTry again in a while, or contact support",
                                boldedPortion: nil)
        case .myInfoFailed:
            return BoldableText(fullText: "We're unable to retrieve your info from MyInfo.\n\n. Try later.",
                                boldedPortion: nil)
        case .paymentFailedGeneric:
            return BoldableText(fullText: "Something went wrong in our system. We have not taken any money from your account. Try again in a while or contact customer support.",
                                boldedPortion: nil)
        case .paymentFailedCardDeclined:
            return BoldableText(fullText: "Your card was declined. Contact your bank or try with another card.",
                                boldedPortion: nil)
        }
    }
    
    var buttonTitle: String {
        switch self {
        case .generic,
             .myInfoFailed:
            return "Try again"
        case .ekycRejected:
            return "Retry"
        case .noInternet:
            return "Check again"
        case .paymentFailedGeneric,
             .paymentFailedCardDeclined:
            return "OK"
        }
    }
}
