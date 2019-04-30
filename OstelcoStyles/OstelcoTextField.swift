//
//  OstelcoTextField.swift
//  OstelcoStyles
//
//  Created by Ellen Shapiro on 4/29/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

/// Base TextField subclass to facilitate easy IBDesignable subclasses.
@IBDesignable
open class OstelcoTextField: UITextField {
    
    public var appTextColor: OstelcoColor = .blackForText {
        didSet {
            self.textColor = self.appTextColor.toUIColor
        }
    }
    
    open override var placeholder: String? {
        didSet {
            guard let holder = self.placeholder else {
                self.attributedPlaceholder = nil
                return
            }
            
            self.attributedPlaceholder = NSAttributedString(string: holder, attributes: [
                .font: self.appFont.toUIFont,
                .foregroundColor: self.appPlaceholderColor.toUIColor
            ])
        }
    }
    
    public var appPlaceholderColor: OstelcoColor = .darkGrey
    
    public var appFont: OstelcoFont = .bodyText {
        didSet {
            self.font = self.appFont.toUIFont
        }
    }
    
    open func commonInit() {
        // Anything which should be happening anytime the text field is set up.
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

class BorderlessTextField: OstelcoTextField {
    
    override func commonInit() {
        super.commonInit()
        
        self.borderStyle = .none
        self.appFont = .bodyText
        self.appTextColor = .blackForText
        self.appPlaceholderColor = .darkGrey
    }
}

class TopBottomBorderedTextField: OstelcoTextField {
    
    private let textRectInsets = UIEdgeInsets(top: 0,
                                              left: 16,
                                              bottom: 0,
                                              right: 16)
    
    private lazy var topBorder: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = OstelcoColor.paleGrey.toUIColor
    
        return view
    }()
    
    private lazy var bottomBorder: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = OstelcoColor.paleGrey.toUIColor
        
        return view
    }()
    
    override func commonInit() {
        super.commonInit()
        
        self.borderStyle = .none
        self.appFont = .bodyText
        self.appTextColor = .blackForText
        self.appPlaceholderColor = .darkGrey
        
        if self.topBorder.superview == nil {
            self.addSubview(self.topBorder)
            
            self.addConstraints([
                self.topBorder.heightAnchor.constraint(equalToConstant: 1),
                self.topBorder.topAnchor.constraint(equalTo: self.topAnchor),
                self.topBorder.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                self.topBorder.trailingAnchor.constraint(equalTo: self.trailingAnchor)
            ])
            
            self.sendSubviewToBack(self.topBorder)
        }
        
        if self.bottomBorder.superview == nil {
            self.addSubview(self.bottomBorder)
            
            self.addConstraints([
                self.bottomBorder.heightAnchor.constraint(equalToConstant: 1),
                self.bottomBorder.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                self.bottomBorder.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                self.bottomBorder.trailingAnchor.constraint(equalTo: self.trailingAnchor)
            ])
            
            self.sendSubviewToBack(self.topBorder)
        }
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: self.textRectInsets)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: self.textRectInsets)
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric,
                      height: 44)
    }
}
