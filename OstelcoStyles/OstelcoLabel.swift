//
//  OstelcoLabel.swift
//  OstelcoStyles
//
//  Created by Ellen Shapiro on 4/23/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

public protocol LabelTapDelegate: class {
    func tappedLink(_ link: Link)
}

/// Base label subclass to facilitate easy IBDesignable subclasses.
@IBDesignable
open class OstelcoLabel: UILabel {
    
    public weak var tapDelegate: LabelTapDelegate?
    
    private lazy var tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
    
    var linkableText: LinkableText?
    
    public var appTextColor: OstelcoColor = .text {
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
    
    public func setFullText(_ fullText: String, withAttributedPortion attributedPortion: String, attributes: [NSAttributedString.Key: Any]) {
        self.setFullText(fullText, withAttributedPortions: [attributedPortion], attributes: attributes)
    }
    
    open func setFullText(_ fullText: String, withAttributedPortions attributedPortions: [String], attributes: [NSAttributedString.Key: Any]) {
        let attributedRanges = attributedPortions.compactMap { fullText.range(of: $0) }
        let attributed = NSMutableAttributedString(string: fullText, attributes: [
            .font: self.appFont.toUIFont,
            .foregroundColor: self.appTextColor.toUIColor
        ])
        
        for range in attributedRanges {
            attributed.addAttributes(attributes, range: NSRange(range, in: fullText))
        }
        
        self.attributedText = attributed
    }
    
    public func setLinkableText(_ linkableText: LinkableText) {
        guard let linkedBits = linkableText.linkedBits else {
            // Nothing to link!
            self.text = linkableText.fullText
            return
        }
        
        self.addTapRecognizer()
        
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: OstelcoColor.textLink.toUIColor
        ]
        self.linkableText = linkableText
        self.setFullText(linkableText.fullText, withAttributedPortions: linkedBits.map({ $0.text }), attributes: attributes)
    }
    
    open func addTapRecognizer() {
        guard self.tapRecognizer.view == nil else {
            // already added, don't re-add
            return
        }
        
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(self.tapRecognizer)
    }
    
    @objc private func handleTap(_ recognizer: UITapGestureRecognizer) {
        let touchPoint = recognizer.location(in: self)
        guard let index = characterIndex(at: touchPoint) else {
            // Nothing to handle here.
            return
        }
        if let link = linkableText?.linkedText(at: index) {
            tapDelegate?.tappedLink(link)
        }
    }
    
    private func characterIndex(at point: CGPoint) -> Int? {
        guard let attributedText = self.attributedText else {
            return nil
        }
        
        // Fix issue where font isn't properly set when passing attributed string to text storage
        let fullStringRange = NSRange(location: 0, length: attributedText.length)
        let mutable = NSMutableAttributedString(attributedString: attributedText)
        mutable.addAttribute(.font, value: self.appFont.toUIFont, range: fullStringRange)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = self.textAlignment
        mutable.addAttribute(.paragraphStyle, value: paragraphStyle, range: fullStringRange)
        
        // OK now let's let core text do some math for us
        let textStorage = NSTextStorage(attributedString: mutable)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        
        let textContainer = NSTextContainer(size: self.frame.size)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = self.numberOfLines
        textContainer.lineBreakMode = self.lineBreakMode
        layoutManager.addTextContainer(textContainer)

        return layoutManager.characterIndex(for: point,
                                            in: textContainer,
                                            fractionOfDistanceBetweenInsertionPoints: nil)
        
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
        self.appTextColor = .highlighted
        self.appFont = OstelcoFont(fontType: .bold,
                                   fontSize: .data)
        self.smallFont = OstelcoFont(fontType: .bold,
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
        self.appTextColor = .highlighted
        self.appFont = OstelcoFont(fontType: .regular,
                                   fontSize: .finePrint)
    }
}

// MARK: - Header Labels

public class Heading1Label: OstelcoLabel {
    
    public override func commonInit() {
        super.commonInit()
        self.appTextColor = .text
        self.appFont = OstelcoFont(fontType: .bold,
                                   fontSize: .heading1)
    }
}

public class Heading2Label: OstelcoLabel {
    
    public override func commonInit() {
        super.commonInit()
        self.appTextColor = .text
        self.appFont = OstelcoFont(fontType: .bold,
                                   fontSize: .heading2)
    }
}

// MARK: - Body Etc text

public class OnboardingLabel: OstelcoLabel {
    
    public override func commonInit() {
        super.commonInit()
        self.appTextColor = .text
        self.appFont = OstelcoFont(fontType: .medium,
                                   fontSize: .onboarding)
    }
}

public class BodyTextBoldLabel: OstelcoLabel {
    
    public override func commonInit() {
        super.commonInit()
        self.appTextColor = .text
        self.appFont = OstelcoFont(fontType: .bold,
                                   fontSize: .body)
    }
}

public class BodyTextLabel: OstelcoLabel {
    
    public override func commonInit() {
        super.commonInit()
        self.appTextColor = .text
        self.appFont = OstelcoFont(fontType: .regular,
                                   fontSize: .body)
    }
    
    public func setBoldableText(_ boldable: BoldableText) {
        guard let boldedPortion = boldable.boldedPortion else {
            self.text = boldable.fullText
            return
        }
        
        self.setFullText(boldable.fullText,
                         withAttributedPortion: boldedPortion,
                         attributes: [
                            .font: OstelcoFont(fontType: .bold, fontSize: self.appFont.fontSize).toUIFont
                         ])
    }
}

public class StepsTextLabel: OstelcoLabel {
    
    public override var isEnabled: Bool {
        didSet {
            if self.isEnabled {
                self.appTextColor = .highlighted
            } else {
                self.appTextColor = .disabled
            }
        }
    }
    
    public override func commonInit() {
        super.commonInit()
        self.appTextColor = .highlighted
        self.appFont = OstelcoFont(fontType: .medium,
                                   fontSize: .body)
    }
}

public class StepNumberLabel: OstelcoLabel {
    
    public override func commonInit() {
        super.commonInit()
        self.appTextColor = .disabled
        self.appFont = OstelcoFont(fontType: .medium,
                                   fontSize: .body)
        // self.alpha = 0.5
    }
}

public class UpdateTextLabel: OstelcoLabel {
    
    public override func commonInit() {
        super.commonInit()
        self.appTextColor = .text
        self.appFont = OstelcoFont(fontType: .medium,
                                   fontSize: .body)
    }
}

public class UpdateTextGreyLabel: OstelcoLabel {
    
    public override func commonInit() {
        super.commonInit()
        self.appTextColor = .textSecondary
        self.appFont = OstelcoFont(fontType: .medium,
                                   fontSize: .body)
    }
}

public class ErrorTextLabel: OstelcoLabel {
    
    public override func commonInit() {
        super.commonInit()
        self.appTextColor = .statusError
        self.appFont = OstelcoFont(fontType: .regular,
                                   fontSize: .body)
    }
}

public class AppVersionTextLabel: OstelcoLabel {
    
    public override func commonInit() {
        super.commonInit()
        self.appTextColor = .textSecondary
        self.appFont = OstelcoFont(fontType: .medium,
                                   fontSize: .finePrint)
    }
}

public class InputFieldHeadlineLabel: OstelcoLabel {
    
    public override func commonInit() {
        super.commonInit()
        self.appFont = OstelcoFont(fontType: .regular,
                                   fontSize: .inputHeadline)
        self.appTextColor = .text
        self.alpha = 0.75
    }
}
