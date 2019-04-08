//
//  File+Current.swift
//  Core
//
//  Created by Ellen Shapiro on 4/8/19.
//

import Foundation
import Files
import ShellOut

enum FileError: Error {
    case cantAccessSRCROOT
}

extension File {
    
    public static func sourceRoot() throws -> Folder {
        let root = try shellOut(to: ShellOutCommand(string: "echo $SRCROOT"))
        guard root.hasSuffix("iOS") else {
            throw FileError.cantAccessSRCROOT
        }
        
        return try Folder(path: root)
    }
}
