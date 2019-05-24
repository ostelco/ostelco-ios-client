//
//  OnboardingPageViewController.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 4/26/19.
//  Copyright © 2019 mac. All rights reserved.
//

import AVFoundation
import ostelco_core
import OstelcoStyles
import UIKit

enum OnboardingPage: Int, CaseIterable {
    case whatIsOya
    case noNeedToChange
    case fullyDigital
    
    var gifVideo: GifVideo {
        switch self {
        case .whatIsOya:
            return .arrow_up
        case .noNeedToChange:
            return .heart
        case .fullyDigital:
            return .app
        }
    }
    
    var copyText: String {
        switch self {
        case .whatIsOya:
            return """
            OYA is a simple way to get extra mobile data
            
            No monthly fees
            
            Just extra data when you need it!
            """
        case .noNeedToChange:
            return """
            No need to change telco!
            
            When you’re running low on data, get some extra from OYA
            
            OYA data never expires, so it’s there when you need it!
            """
        case .fullyDigital:
            return """
            OYA is fully digital
            
            No need to wait for a SIM card in the mail
            
            Try it now, with 2GB free data!
            """
        }
    }
    
    var viewController: OnboardingPageViewController {
        return OnboardingPageViewController.fromStoryboard(with: self)
    }
}

class OnboardingPageViewController: UIViewController {
    
    @IBOutlet private var copyLabel: UILabel!
    
    @IBOutlet private var gifView: LoopingVideoView!
    
    // This is set up in the convenience constructor
    // swiftlint:disable:next implicitly_unwrapped_optional
    private(set) var onboardingPage: OnboardingPage!
    
    /// Convenience constructor
    ///
    /// - Parameter page: The page you wish to display.
    static func fromStoryboard(with page: OnboardingPage) -> OnboardingPageViewController {
        let vc = self.fromStoryboard()
        vc.onboardingPage = page
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gifView.videoURL = self.onboardingPage.gifVideo.url
        self.copyLabel.text = self.onboardingPage.copyText
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.gifView.play()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.gifView.pause()
    }
}

extension OnboardingPageViewController: StoryboardLoadable {
    
    static var storyboard: Storyboard {
        return .login
    }
    
    static var isInitialViewController: Bool {
        return false
    }
}
