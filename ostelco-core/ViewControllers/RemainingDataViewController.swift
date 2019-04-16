//
//  RemainingDataView.swift
//  ostelco-core
//
//  Created by Ellen Shapiro on 4/10/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

/// A view controller showing the user's remaining data.
/// Designed to be embedded in other view controllers across both the app and extensions.
public final class RemainingDataViewController: UIViewController, NibLoadable {
    
    @IBOutlet private var amountLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    
    /// How many gigs of data does the user have remaining?
    public var dataRemainingInGigabytes: Double = 0.0 {
        didSet {
            self.configureAmountLabel()
        }
    }
    
    /// What color should all the labels' text be?
    public var textColor: UIColor = .blue {
        didSet {
            self.updateTextColor()
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.configureAmountLabel()
    }
    
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.configureAmountLabel()
        self.updateTextColor()
    }
    
    private func configureAmountLabel() {
        guard self.amountLabel != nil else {
            // View hasn't loaded yet, please try your call again later.
            return
        }
        
        self.amountLabel.text = String.localizedStringWithFormat("%.1f GB", self.dataRemainingInGigabytes)
        self.descriptionLabel.text = "Left"
    }
    
    private func updateTextColor() {
        guard self.amountLabel != nil else {
            // View hasn't loaded yet, please try your call again later.
            return
        }
        
        self.amountLabel.textColor = self.textColor
        self.descriptionLabel.textColor = self.textColor
    }
}
