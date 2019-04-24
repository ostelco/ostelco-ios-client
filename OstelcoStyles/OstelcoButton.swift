//
//  OstelcoButton.swift
//  OstelcoStyles
//
//  Created by Ellen Shapiro on 4/23/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

/// Base button subclass to facilitate easy IBDesignable subclasses.
/// NOTE: When adding any of these in InterfaceBuilder, make sure to select a `Custom` button style.
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
                self.alpha = 0.15
            }
        }
    }
    
    // MARK: - Initializers
    
    open func commonInit() {
        // Anything which should be happening anytime the button is set up.
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
        self.layer.cornerRadius = self.defaultCornerRadius
        self.clipsToBounds = true
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
        self.appFont = OstelcoFont(fontType: .bold, fontSize: .body)
        self.addRoundingAndShadow(background: .oyaBlue)
    }
    
    private func addRoundingAndShadow(background color: OstelcoColor) {
        let cornerRadius = self.intrinsicContentSize.height / 2
        let shapeLayer = CAShapeLayer()
        
        shapeLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius).cgPath
        
        shapeLayer.fillColor = color.toUIColor.cgColor
        shapeLayer.shadowColor = color.toUIColor.cgColor
        shapeLayer.shadowPath = shapeLayer.path
        shapeLayer.shadowOpacity = 0.3
        shapeLayer.shadowOffset = CGSize(width: 0, height: 7)
        shapeLayer.shadowRadius = 18
        
        self.layer.insertSublayer(shapeLayer, at: 0)
    }
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric,
                      height: 55)
    }
}

public class CheckButton: OstelcoButton {
    
    private let checkSize: CGFloat = 25
  
    @IBInspectable
    var isChecked: Bool = false {
        didSet {
            self.configureForChecked()
        }
    }
    
    private lazy var shapeLayer = CAShapeLayer()
    
    public override func commonInit() {
        super.commonInit()
        
        self.appTitleColor = .white
        self.appFont = OstelcoFont(fontType: .bold,
                                   fontSize: .body)
        self.tintColor = .white
        self.setupRoundedCenter(background: .oyaBlue)
        self.configureForChecked()
    }
    
    private func configureForChecked() {
        if self.isChecked {
            self.setTitle("✓", for: .normal)
            // TODO: Localize accessibility
            self.accessibilityLabel = "Checked"
            self.shapeLayer.fillColor = OstelcoColor.oyaBlue.toUIColor.cgColor
        } else {
            self.setTitle(nil, for: .normal)
            self.accessibilityLabel = "Unchecked"
            self.shapeLayer.fillColor = nil
        }
    }
    
    public func setupRoundedCenter(background color: OstelcoColor) {
        let cornerRadius = self.checkSize / 2
        let inset = (self.intrinsicContentSize.width - self.checkSize) / 2
        self.shapeLayer.path = UIBezierPath(roundedRect: self.bounds.insetBy(dx: inset, dy: inset),
                                            cornerRadius: cornerRadius).cgPath
        self.shapeLayer.strokeColor = color.toUIColor.cgColor
        self.shapeLayer.lineWidth = 1
                
        self.layer.insertSublayer(self.shapeLayer, at: 0)
    }
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: 44,
                      height: 44)
    }
}
