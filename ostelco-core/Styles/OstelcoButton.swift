//
//  OstelcoButton.swift
//  ostelco-core
//
//  Created by Ellen Shapiro on 4/23/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

/// NOTE: When adding this in InterfaceBuilder, make sure to use a `Custom` button style.
@IBDesignable
open class OstelcoButton: UIButton {
    
    public let defaultCornerRadius: CGFloat = 8
    
    public var appTitleColor: OstelcoColor = .blackForText {
        didSet {
            self.setTitleColor(self.appTitleColor.toUIColor, for: .normal)
        }
    }
    
    public var selectedAppTitleColor: OstelcoColor? {
        didSet {
            let color = self.selectedAppTitleColor?.toUIColor
            self.setTitleColor(color, for: .selected)
            self.setTitleColor(color, for: [.selected, .highlighted])
            self.setTitleColor(color, for: .highlighted)
        }
    }
    
    public var appBackgroundColor: OstelcoColor? {
        didSet {
            let color = self.appBackgroundColor?.toUIColor
            let image = color?.toPixelImage
            self.setBackgroundImage(image, for: .normal)
        }
    }
    
    public var selectedAppBackgroundColor: OstelcoColor? {
        didSet {
            let color = self.selectedAppBackgroundColor?.toUIColor
            let image = color?.toPixelImage
            self.setBackgroundImage(image, for: .selected)
            self.setBackgroundImage(image, for: [.selected, .highlighted])
            self.setBackgroundImage(image, for: .highlighted)
        }
    }
    
    public var appFont: OstelcoFont = .bodyText {
        didSet {
            self.titleLabel?.font = self.appFont.toUIFont
        }
    }
    
    // MARK: - Overridden variables
    
    open override var isEnabled: Bool {
        didSet {
            if self.isEnabled {
                self.alpha = 1
            } else {
                self.alpha = 0.4
            }
        }
    }
    
    // MARK: - Initializers
    
    open func commonInit() {
        // Anything which should be happening anytime the label is set up.
    }
    
    convenience init() {
        self.init(frame: .zero)
        self.commonInit()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    // MARK: - Overridden lifecycle functions
    
    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.commonInit()
    }
}

public class LinkTextButton: OstelcoButton {
    
    public override func commonInit() {
        super.commonInit()
        
        self.appTitleColor = .oyaBlue
        self.appFont = OstelcoFont(fontType: .regular,
                                   fontSize: .body)
    }
}

public class PrimaryButton: OstelcoButton {
    
    public override func commonInit() {
        super.commonInit()
        self.appBackgroundColor = .oyaBlue
        self.appTitleColor = .white
        self.appFont = OstelcoFont(fontType: .semibold,
                                   fontSize: .secondary)
        
        self.clipsToBounds = true
        self.layer.cornerRadius = self.defaultCornerRadius
    }
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric,
                      height: 50)
    }
}

public class SmallButton: OstelcoButton {
    
    public override func commonInit() {
        super.commonInit()
        self.contentEdgeInsets = UIEdgeInsets(top: 7,
                                              left: 14,
                                              bottom: 7,
                                              right: 14)
        
        self.appBackgroundColor = .oyaBlue
        self.appTitleColor = .white
        self.appFont = OstelcoFont(fontType: .semibold,
                                   fontSize: .smallButton)
    }
}

public class BuyButton: OstelcoButton {
    
    public override func commonInit() {
        super.commonInit()
        self.appTitleColor = .white
        self.addRoundingAndShadow(background: .oyaBlue)
    }
    
    private func addRoundingAndShadow(background color: OstelcoColor) {
        let cornerRadius = self.intrinsicContentSize.height / 2
        guard let context = UIGraphicsGetCurrentContext() else {
            assertionFailure("Could not access graphics context!")
            // Let's just make it rounded and blue and forget about the damned shadow
            self.appBackgroundColor = color
            self.layer.cornerRadius = cornerRadius
            self.clipsToBounds = true
            return
        }
        
        context.saveGState()
        
        let roundedRectPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius)
        
        let blurColor = color.toUIColor.withAlphaComponent(0.3)
        
        context.setShadow(offset: CGSize(width: 0, height: 7),
                          blur: 18,
                          color: blurColor.cgColor)
        context.addPath(roundedRectPath.cgPath)
        context.setFillColor(color.toUIColor.cgColor)
        context.closePath()
        context.fillPath()
        
        context.restoreGState()
    }
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric,
                      height: 55)
    }
}
