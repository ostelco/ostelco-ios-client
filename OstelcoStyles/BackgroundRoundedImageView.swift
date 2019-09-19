//
//  BackgroundRoundedImageView.swift
//  dev-ostelco-ios-clientTests
//
//  Created by Ellen Shapiro on 5/23/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

@IBDesignable
public class BackgroundRoundedImageView: UIImageView {
    
    var appBackgroundColor: OstelcoColor = .highlighted
    var appTintColor: OstelcoColor = .primaryButtonLabel
    
    private func commonInit() {
        self.clipsToBounds = true
        self.configureBackground()
        self.configureTint()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    public override init(image: UIImage?) {
        super.init(image: image)
        self.commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.commonInit()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.width / 2
    }
    
    private func configureBackground() {
        self.backgroundColor = self.appBackgroundColor.toUIColor
    }
    
    private func configureTint() {
        self.tintColor = self.appTintColor.toUIColor
    }
}
