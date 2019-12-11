//
//  PendingVerificationViewController.swift
//  ostelco-ios-client
//
//  Created by Prasanth Ullattil on 28/02/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

protocol PendingVerificationDelegate: class {
    func checkStatus()
    func reportAnalytics()
}

class PendingVerificationViewController: UIViewController {
    
    // for PushNotificationHandling
    var pushNotificationObserver: NSObjectProtocol?
    
    // for DidBecomeActiveHandling
    var didBecomeActiveObserver: NSObjectProtocol?
    
    @IBOutlet private var gifView: LoopingVideoView!
    var spinnerView: UIView?

    weak var delegate: PendingVerificationDelegate?
    
    // MARK: - View Lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delegate?.reportAnalytics()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gifView.videoURL = GifVideo.time.url(for: traitCollection.userInterfaceStyle)
        gifView.play()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        addPushNotificationListener()
        addDidBecomeActiveObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removePushNotificationListener()
        removeDidBecomeActiveObserver()
    }
    
    // MARK: - IBActions
    
    @IBAction private func needHelpTapped(_ sender: Any) {
        showNeedHelpActionSheet()
    }
    
    @IBAction private func `continue`(_ sender: Any) {
        spinnerView = showSpinner()
        delegate?.checkStatus()
    }
}

// MARK: - StoryboardLoadable

extension PendingVerificationViewController: StoryboardLoadable {
    
    static var storyboard: Storyboard {
        return .ekyc
    }
    
    static var isInitialViewController: Bool {
        return false
    }
}

// MARK: - PushNotificationHandling

extension PendingVerificationViewController: PushNotificationHandling {
    
    func handlePushNotification(_ notification: PushNotificationContainer) {
        delegate?.checkStatus()
    }
}

// MARK: - DidBecomeActiveHandling

extension PendingVerificationViewController: DidBecomeActiveHandling {
    
    func handleDidBecomeActive() {
        delegate?.checkStatus()
    }
}
