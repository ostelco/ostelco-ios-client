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
}

public class DataDecimalsLabel: OstelcoLabel {
    
    public override func commonInit() {
        super.commonInit()
        self.appTextColor = .oyaBlue
        self.appFont = OstelcoFont(fontType: .alternateBold,
                                   fontSize: .dataDecimals)
    }
}

public class DataLeftLabel: OstelcoLabel {
    
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
