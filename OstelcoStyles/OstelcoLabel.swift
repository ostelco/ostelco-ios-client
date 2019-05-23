//
//  OstelcoLabel.swift
//  OstelcoStyles
//
//  Created by Ellen Shapiro on 4/23/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

/// Base label subclass to facilitate easy IBDesignable subclasses.
@IBDesignable
open class OstelcoLabel: UILabel {
    
    public var appTextColor: OstelcoColor = .blackForText {
        didSet {
            self.textColor = self.appTextColor.toUIColor
        }
    }
    
    public var appFont: OstelcoFont = .bodyText {
        didSet {
            self.font = self.appFont.toUIFont
        }
    }
        
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
    
    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.commonInit()
    }
    
    open func setFullText(_ fullText: String, withAttributedPortion attributedPortion: String, attributes: [NSAttributedString.Key: Any]) {
        guard let range = fullText.range(of: attributedPortion) else {
            assertionFailure("You're trying to set attributed text that's not in the full text!")
            // In prod: Fall back to just setting the text normally.
            self.text = fullText
            return
        }
        
        let attributed = NSMutableAttributedString(string: fullText, attributes: [
            .font: self.appFont.toUIFont,
            .foregroundColor: self.appTextColor.toUIColor
        ])
        
        attributed.addAttributes(attributes, range: NSRange(range, in: fullText))
        
        self.attributedText = attributed
    }
}

// MARK: - Data labels

public class DataAmountOnHomeLabel: OstelcoLabel {
    
    public var smallFont: OstelcoFont!
    
    @IBInspectable
    public var dataAmountString: String? {
        didSet {
            self.configureForDataAmountString()
        }
    }

    public override func commonInit() {
        super.commonInit()
        self.appTextColor = .oyaBlue
        self.appFont = OstelcoFont(fontType: .alternateBold,
                                   fontSize: .data)
        self.smallFont = OstelcoFont(fontType: .alternateBold,
                                     fontSize: .dataDecimals)
        self.configureForDataAmountString()
    }

    /// Make the string with all the styles required for the balance text
    /// Input text e.g. "54.5 GB"
    private func configureForDataAmountString() {
        guard let text = self.dataAmountString else {
            // Nothing to format.
            self.text = nil
            return
        }

        // Split text to 2 parts, number and units
        let textArray: [String] = text.components(separatedBy: " ")
        guard textArray.count >= 2 else {
            // We don't have enough info to format this correctly, just set it normally.
            self.text = text
            return
        }
    
        // Split number string to integer and decimal parts.
        let decimalSeparator: String = Locale.current.decimalSeparator!
        let numberBit = textArray[0]
        let numberArray = numberBit.components(separatedBy: decimalSeparator)
        guard numberArray.count >= 2 else {
            // There isn't a decimal separator, don't bother formatting.
            self.text = text
            return
        }
        
        let decimalPart = numberArray[1]
        let offset = self.appFont.toUIFont.capHeight - self.smallFont.toUIFont.capHeight
        self.setFullText(text,
                         withAttributedPortion: decimalSeparator + decimalPart,
                         attributes: [
                            .font: self.smallFont.toUIFont,
                            .baselineOffset: offset,
                            .foregroundColor: self.appTextColor.toUIColor
                        ])
    }
}

public class DataRemainingLabel: OstelcoLabel {
    
    public override func commonInit() {
        super.commonInit()
        self.appTextColor = .oyaBlue
        self.appFont = OstelcoFont(fontType: .regular,
                                   fontSize: .finePrint)
    }
}

// MARK: - Header Labels

public class Heading1Label: OstelcoLabel {
    
    public override func commonInit() {
        super.commonInit()
        self.appTextColor = .black
        self.appFont = OstelcoFont(fontType: .heavy,
                                   fontSize: .heading1)
    }
}

public class Heading2Label: OstelcoLabel {
    
    public override func commonInit() {
        super.commonInit()
        self.appTextColor = .black
        self.appFont = OstelcoFont(fontType: .bold,
                                   fontSize: .heading2)
    }
}

// MARK: - Body Etc text

public class OnboardingLabel: OstelcoLabel {
    
    public override func commonInit() {
        super.commonInit()
        self.appTextColor = .blackForText
        self.appFont = OstelcoFont(fontType: .medium,
                                   fontSize: .onboarding)
    }
    
    public func setFullText(_ fullText: String, withLinkedPortion linkedPortion: String) {
        self.addTapRecognizer()
        self.setFullText(fullText,
                         withAttributedPortion: linkedPortion,
                         attributes: [
                            .foregroundColor: OstelcoColor.oyaBlue.toUIColor
                         ])
    }
}

public class BodyTextBoldLabel: OstelcoLabel {
    
    public override func commonInit() {
        super.commonInit()
        self.appTextColor = .blackForText
        self.appFont = OstelcoFont(fontType: .bold,
                                   fontSize: .body)
    }
}

public class BodyTextLabel: OstelcoLabel {
    
    public override func commonInit() {
        super.commonInit()
        self.appTextColor = .blackForText
        self.appFont = OstelcoFont(fontType: .regular,
                                   fontSize: .body)
    }
    
    public func setFullText(_ fullText: String, withBoldedPortion boldedPortion: String) {
        self.setFullText(fullText,
                         withAttributedPortion: boldedPortion,
                         attributes: [
                            .font: OstelcoFont(fontType: .bold, fontSize: self.appFont.fontSize).toUIFont
                         ])
    }
    
    public func setFullText(_ fullText: String, withLinkedPortion linkedPortion: String) {
        self.addTapRecognizer()
        self.setFullText(fullText,
                         withAttributedPortion: linkedPortion,
                         attributes: [
                            .foregroundColor: OstelcoColor.oyaBlue.toUIColor
                         ])
    }
}

public class StepsTextLabel: OstelcoLabel {
    
    public override var isEnabled: Bool {
        didSet {
            if self.isEnabled {
                self.appTextColor = .blackForText
            } else {
                self.appTextColor = .greyedOut
            }
        }
    }
    
    public override func commonInit() {
        super.commonInit()
        self.appTextColor = .blackForText
        self.appFont = OstelcoFont(fontType: .medium,
                                   fontSize: .body)
    }
}

public class StepNumberLabel: OstelcoLabel {
    
    public override func commonInit() {
        super.commonInit()
        self.appTextColor = .oyaBlue
        self.appFont = OstelcoFont(fontType: .medium,
                                   fontSize: .body)
        self.alpha = 0.5
    }
}

public class UpdateTextLabel: OstelcoLabel {
    
    public override func commonInit() {
        super.commonInit()
        self.appTextColor = .blackForText
        self.appFont = OstelcoFont(fontType: .medium,
                                   fontSize: .secondary)
    }
}

public class UpdateTextGreyLabel: OstelcoLabel {
    
    public override func commonInit() {
        super.commonInit()
        self.appTextColor = .darkGrey
        self.appFont = OstelcoFont(fontType: .medium,
                                   fontSize: .secondary)
    }
}

public class ErrorTextLabel: OstelcoLabel {
    
    public override func commonInit() {
        super.commonInit()
        self.appTextColor = .watermelon
        self.appFont = OstelcoFont(fontType: .regular,
                                   fontSize: .body)
    }
}

public class AppVersionTextLabel: OstelcoLabel {
    
    public override func commonInit() {
        super.commonInit()
        self.appTextColor = .darkGrey
        self.appFont = OstelcoFont(fontType: .medium,
                                   fontSize: .finePrint)
    }
}
