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
    
    fileprivate var roundedBackgroundLayer: CAShapeLayer?
    
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
    
    // MARK: - Shadow helpers
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        guard let shapeLayer = self.roundedBackgroundLayer else {
            return
        }
        
        let cornerRadius = self.intrinsicContentSize.height / 2
        shapeLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius).cgPath
        shapeLayer.shadowPath = shapeLayer.path
    }
    
    fileprivate func addRoundingAndShadow(background color: OstelcoColor) {
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
        self.roundedBackgroundLayer = shapeLayer
    }
}

public class LinkTextButton: OstelcoButton {
    
    public override func commonInit() {
        super.commonInit()
        
        self.appTitleColor = .oyaBlue
        self.tintColor = self.appTitleColor.toUIColor
        self.appFont = OstelcoFont(fontType: .regular,
                                   fontSize: .body)
    }
}

public class PrimaryButton: OstelcoButton {
    
    public override func commonInit() {
        super.commonInit()
        self.appTitleColor = .white
        self.appFont = OstelcoFont(fontType: .semibold,
                                   fontSize: .secondary)
        
        self.addRoundingAndShadow(background: .oyaBlue)
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
        
        self.appTitleColor = .white
        self.appFont = OstelcoFont(fontType: .semibold,
                                   fontSize: .smallButton)
        self.addRoundingAndShadow(background: .oyaBlue)
    }
}

public class BuyButton: OstelcoButton {
    
    public override func commonInit() {
        super.commonInit()
        self.appTitleColor = .white
        self.appFont = OstelcoFont(fontType: .bold, fontSize: .body)
        self.addRoundingAndShadow(background: .oyaBlue)
    }
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric,
                      height: 55)
    }
}

public class CheckButton: OstelcoButton {
    
    private let checkSize: CGFloat = 30
  
    @IBInspectable
    public var isChecked: Bool = false {
        didSet {
            self.configureForChecked()
        }
    }
    
    private lazy var shapeLayer = CAShapeLayer()
    
    public override func commonInit() {
        super.commonInit()
        
        self.appTitleColor = .white
        self.appFont = OstelcoFont(fontType: .bold,
                                   fontSize: .onboarding)
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
        let inset = (self.intrinsicContentSize.width - self.checkSize) / 2
        self.shapeLayer.path = UIBezierPath(roundedRect: self.bounds.insetBy(dx: inset, dy: inset),
                                            cornerRadius: 5).cgPath
        self.shapeLayer.strokeColor = color.toUIColor.cgColor
        self.shapeLayer.lineWidth = 1
                
        self.layer.insertSublayer(self.shapeLayer, at: 0)
    }
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: 44,
                      height: 44)
    }
}

public class RadioButton: OstelcoButton {
    
    private let outerCircleWidth: CGFloat = 30
    private let innerCircleWidth: CGFloat = 14
    
    private lazy var outerLayer = CAShapeLayer()
    private lazy var innerLayer = CAShapeLayer()
    
    @IBInspectable
    public var isCurrentSelected: Bool = false {
        didSet {
            self.configureForSelected()
        }
    }
    
    public override func commonInit() {
        super.commonInit()
        self.setupLayers(background: .oyaBlue)
        self.configureForSelected()
    }
    
    private func configureForSelected() {
        if self.isCurrentSelected {
            self.layer.addSublayer(self.innerLayer)
            // TODO: Localize accessibility
            self.accessibilityLabel = "Selected"
            self.layer.addSublayer(self.innerLayer)
        } else {
            self.innerLayer.removeFromSuperlayer()
            self.accessibilityLabel = "Deselected"
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: 44,
                      height: 44)
    }
    
    private func setupLayers(background color: OstelcoColor) {
        let outerLayerInset = (self.intrinsicContentSize.width - self.outerCircleWidth) / 2
        let outerCornerRadius = self.outerCircleWidth / 2
        self.outerLayer.path = UIBezierPath(roundedRect: self.bounds.insetBy(dx: outerLayerInset, dy: outerLayerInset),
                                            cornerRadius: outerCornerRadius).cgPath
        self.outerLayer.strokeColor = color.toUIColor.cgColor
        self.outerLayer.lineWidth = 1
        self.outerLayer.fillColor = nil
        
        self.layer.insertSublayer(self.outerLayer, at: 0)
        
        let innerLayerInset = (self.intrinsicContentSize.width - self.innerCircleWidth) / 2
        let innerCornerRadius = self.innerCircleWidth / 2
        self.innerLayer.path = UIBezierPath(roundedRect: self.bounds.insetBy(dx: innerLayerInset, dy: innerLayerInset),
                                            cornerRadius: innerCornerRadius).cgPath
        
        self.innerLayer.fillColor = color.toUIColor.cgColor
        self.innerLayer.strokeColor = color.toUIColor.cgColor
    }
}
