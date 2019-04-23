//
//  OstelcoFont.swift
//  OstelcoStyles
//
//  Created by Ellen Shapiro on 4/23/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

/// The combination of a font type and size which makes a font.
public class OstelcoFont {
    public let fontType: OstelcoFontType
    public let fontSize: OstelcoFontSize
    
    public init(fontType: OstelcoFontType,
                fontSize: OstelcoFontSize) {
        OstelcoFont.registerFontsIfNeeded()
        self.fontType = fontType
        self.fontSize = fontSize
    }
    
    var toUIFont: UIFont {
        guard let font = UIFont(name: self.fontType.fontName, size: self.fontSize.toCGFloat) else {
            debugPrint("- OstelcoFont: Couldn't find font named \(self.fontType.fontName)")
            return UIFont.systemFont(ofSize: self.fontSize.toCGFloat)
        }
        
        return font
    }
    
    public static var bodyText = OstelcoFont(fontType: .regular, fontSize: .body)
    
    /// To use fonts from a framework, you have to register them with CoreText
    /// manually before calling `UIFont(name:size:)`. This method checks if the
    /// registration has already occurred, and then registers all fonts if it hasn't.
    private static var _fontsRegistered = false
    private static func registerFontsIfNeeded() {
        guard !_fontsRegistered else {
            // Fonts are already registered
            return
        }
        
        OstelcoFontType.allCases.forEach { fontType in
            switch fontType {
            case .alternateBold:
                // TODO: Deal with this when we get the telenor font
                break
            default:
                fontType.register()
            }
        }
        
        _fontsRegistered = true
    }
}

/// The types of font as indicated in https://app.zeplin.io/project/5c8b989f46989524fb0258ac/styleguide
public enum OstelcoFontType: CaseIterable {
    case alternateBold
    case bold
    case heavy
    case medium
    case regular
    case semibold
    
    var fontName: String {
        switch self {
        case .alternateBold:
            return "Telenor"
        case .bold:
            return "SFProText-Bold"
        case .heavy:
            return "SFProText-Heavy"
        case .medium:
            return "SFProText-Medium"
        case .regular:
            return "SFProText-Regular"
        case .semibold:
            return "SFProText-Semibold"
        }
    }

    func register() {
        // Grab the current bundle
        let bundle = Bundle(for: OstelcoFont.self)
        
        guard let fontFileURL = bundle.url(forResource: self.fontName, withExtension: "otf") else {
            debugPrint("- OstelcoFont: Could not get path to font \(self.fontName) from bundle")
            return
        }
        
        guard
            let fontData = try? Data(contentsOf: fontFileURL),
            let dataProvider = CGDataProvider(data: fontData as NSData),
            let font = CGFont(dataProvider) else {
                
            debugPrint("- OstelcoFont: Failed to create CGFont from data for \(self.fontName)")
            return
        }
        
        var errorRef: Unmanaged<CFError>?
        if !CTFontManagerRegisterGraphicsFont(font, &errorRef) {
            debugPrint("- OstelcoFont: Failed to register font! Error: \(String(describing: errorRef?.takeUnretainedValue()))")
        }
    }
}
