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
}

// MARK: - Data labels

public class DataAmountOnHomeLabel: OstelcoLabel {

    public override func commonInit() {
        super.commonInit()
        self.appTextColor = .oyaBlue
        self.appFont = OstelcoFont(fontType: .alternateBold,
                                   fontSize: .data)
    }
    override public var text: String? {
        didSet {
            setAttributedText()
        }
    }
    override public var textColor: UIColor? {
        didSet {
            setAttributedText()
        }
    }
    override public var font: UIFont? {
        didSet {
            setAttributedText()
        }
    }

    private func setAttributedText() {
        attributedText = getStylizeBalanceString(text: self.text ?? "")
    }

    // Make the string with all the styles required for the balance text
    // Input text e.g. "54.5 GB"
    private func getStylizeBalanceString(text: String) -> NSMutableAttributedString {
        let decimalSeparator: String = Locale.current.decimalSeparator!
        let bigFont = appFont.toUIFont
        let smallFont = appFont.toUIFont.withSize(OstelcoFontSize.dataDecimals.toCGFloat)
        let color = appTextColor.toUIColor

        // Split text to 2 parts, number and units
        let textArray: [String] = text.components(separatedBy: " ")
        guard textArray.count >= 2 else {
            return NSMutableAttributedString(string: text)
        }

        // Split number string to integer and decimal parts.
        let numberArray: [String] = textArray[0].components(separatedBy: decimalSeparator)
        guard numberArray.count >= 1 else {
            return NSMutableAttributedString(string: text)
        }

        let integerPart = numberArray[0]
        // If there is a decimal part.
        let decimalPart: String? = (numberArray.count >= 2) ? "\(decimalSeparator)\(numberArray[1])": nil
        let unit = " \(textArray[1])"

        // Add integer part with the big font.
        let attrString = NSMutableAttributedString(string: integerPart, attributes: [.font: bigFont, .foregroundColor: color])
        if let decimalPart = decimalPart {
            // Add decimal part including the decimal character
            // This portion of text is aligned to top with a smaller font
            let offset = bigFont.capHeight - smallFont.capHeight
            let attributes: [NSAttributedString.Key: Any] = [
                .font: smallFont,
                .baselineOffset: offset,
                .foregroundColor: color
            ]
            attrString.append(NSMutableAttributedString(string: decimalPart, attributes: attributes))
        }
        // Add the modifier part with bigger font.
        attrString.append(NSMutableAttributedString(string: unit, attributes: [.font: bigFont, .foregroundColor: color]))
        return attrString
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
        guard let range = fullText.range(of: boldedPortion) else {
            assertionFailure("You're trying to set bolded text that's not in the full text!")
            // In prod: Fall back to just setting the text normally.
            self.text = fullText
            return
        }
        
        let attributed = NSMutableAttributedString(string: fullText, attributes: [
            .font: self.appFont.toUIFont,
            .foregroundColor: self.appTextColor.toUIColor
            ])
        
        attributed.addAttributes([
            .font: OstelcoFont(fontType: .bold, fontSize: self.appFont.fontSize).toUIFont
            ], range: NSRange(range, in: fullText))
        
        self.attributedText = attributed
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
