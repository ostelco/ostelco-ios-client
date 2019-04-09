//
//  PlistUpdater.swift
//  Core
//
//  Created by Ellen Shapiro on 4/8/19.
//

import Foundation
import Files
import ShellOut

enum PlistError: Error {
    case noEnvValueForKey(String)
}

struct PlistUpdater {
    
    private static func runPlistBuddyCommand(_ command: String, for file: File) throws {
        
        try shellOut(to: "/usr/libexec/Plistbuddy -c \(command) \(file.path)")
    }
    
    public static func setValue(_ value: String, for key: String, in file: File) throws  {
        try self.runPlistBuddyCommand("\"Set :\(key) \"\(value)\"\"", for: file)
    }
    
    public static func save(file: File) throws {
        try self.runPlistBuddyCommand("Save", for: file)
    }
}
