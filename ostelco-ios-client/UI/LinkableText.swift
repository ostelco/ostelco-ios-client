//
//  LinkableText.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 5/23/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

public struct Link: Equatable {
    public let text: String
    public let url: URL
    
    public init(_ text: String, url: URL) {
        self.text = text
        self.url = url
    }
}

/// A text structure for dealing with a large amount of text that potentially
/// contains multiple links.
public struct LinkableText {
    
    /// The text containing 0 or more links
    public let fullText: String
    
    /// [optional] The bits of text to link, or nil to link nothing.
    public let linkedBits: [Link]?
    
    /// Failable Initializer for text with a single linked portion.
    /// Fails when the `linkedPortion` is non-nil and is not contained within the full text.
    ///
    /// - Parameters:
    ///   - fullText: The text you can potentially add links to
    ///   - linkedPortion: [optional] The text which should be linked, or nil to link nothing.
    public init?(fullText: String, linkedPortion: Link?) {
        if let singleLink = linkedPortion {
            self.init(fullText: fullText, linkedBits: [singleLink])
        } else {
            self.init(fullText: fullText, linkedBits: nil)
        }
    }
    
    /// Failable Initializer for text with mutliple linked portions.
    /// Fails when `linkedBits` is non-nil and not all of its contents are contained
    /// within the full text.
    ///
    /// - Parameters:
    ///   - fullText: The text containing 0 or more links
    ///   - linkedBits: [optional] The bits of text to link, or nil to link nothing.
    public init?(fullText: String, linkedBits: [Link]?) {
        self.fullText = fullText
        
        if let bits = linkedBits {
            for bit in bits {
                guard fullText.contains(bit.text) else {
                    // The full text doesn't contain one of the things we're trying to link.
                    return nil
                }
            }
            
            // Yay, it's all there.
            self.linkedBits = bits
        } else {
            self.linkedBits = nil
        }
    }
    
    private func range(of bit: Link) -> NSRange? {
        let nsRange = (self.fullText as NSString).range(of: bit.text)
        guard nsRange.location != NSNotFound else {
            return nil
        }
        
        return nsRange
    }
    
    private func bit(_ bit: Link, contains index: Int) -> Bool {
        guard let range = self.range(of: bit) else {
            return false
        }
        
        return range.contains(index)
    }
    
    /// Checks to see if the given index has any link at all.
    /// This method is faster to check if there's only one link in a given
    /// `linkableText`.
    ///
    /// - Parameter index: The index to check for a link
    /// - Returns: True if that index is part of a link, false if not.
    public func isIndexLinked(_ index: Int) -> Bool {
        guard
            index < (self.fullText as NSString).length,
            let bits = self.linkedBits,
            !bits.isEmpty else {
                return false
        }
        
        return bits.contains(where: { self.bit($0, contains: index) })
    }
    
    /// Returns the link at the given index
    ///
    /// - Parameter index: The index to check for linked text
    /// - Returns: [Optional] The linked text at the given index, or nil if the index
    ///            did not contain a link.
    public func linkedText(at index: Int) -> Link? {
        guard
            index < (self.fullText as NSString).length,
            let bits = self.linkedBits,
            !bits.isEmpty else {
                return nil
        }
        
        guard self.isIndexLinked(index) else {
            return nil
        }
        
        return bits.first(where: { self.bit($0, contains: index) })
    }
}
