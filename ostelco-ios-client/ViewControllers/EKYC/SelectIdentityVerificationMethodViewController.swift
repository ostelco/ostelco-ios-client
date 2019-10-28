//
//  SelectIdentityVerificationMethodViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 3/16/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import SafariServices
import OstelcoStyles
import ostelco_core

protocol SelectIdentityVerificationMethodDelegate: class {
    func selected(option: IdentityVerificationOption)
}

class SelectIdentityVerificationMethodViewController: UIViewController {
    
    var spinnerView: UIView?
    var options: [IdentityVerificationOption]!
    
    @IBOutlet private var singpassViews: [UIView]?
    @IBOutlet private var jumioViews: [UIView]?
    
    weak var delegate: SelectIdentityVerificationMethodDelegate?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        removeSpinner(spinnerView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !options.contains(.singpass) {
            singpassViews?.forEach({ $0.isHidden = true })
        }
        
        if !options.contains(.scanIC) && !options.contains(.jumio) {
            jumioViews?.forEach({ $0.isHidden = true })
        }
    }
    
    @IBAction private func singpassTapped(_ sender: Any) {
        delegate?.selected(option: .singpass)
    }
    
    @IBAction private func jumioTapped(_ sender: Any) {
        if options.contains(.scanIC) {
            delegate?.selected(option: .scanIC)
        }
        if options.contains(.jumio) {
            delegate?.selected(option: .jumio)
        }
    }
    
    @IBAction private func needHelpTapped(_ sender: Any) {
        showNeedHelpActionSheet()
    }
}

extension SelectIdentityVerificationMethodViewController: StoryboardLoadable {
    
    static var storyboard: Storyboard {
        return .ekyc
    }
    
    static var isInitialViewController: Bool {
        return false
    }
}
