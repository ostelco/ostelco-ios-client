//
//  PlistUpdater.swift
//  Core
//
//  Created by Ellen Shapiro on 4/8/19.
//

import Foundation
import Files
import ShellOut

public struct PlistUpdater {
    
    public enum Error: Swift.Error {
        case couldNotLoadData(path: String)
        case couldNotTransformDataToDictionary(path: String)
    }
    
    private static func runPlistBuddyCommand(_ command: String, for file: File) throws {
        
        try shellOut(to: "/usr/libexec/Plistbuddy -c \(command) \(file.path)")
    }
    
    public static func setValue(_ value: String, for key: String, in file: File) throws  {
        try self.runPlistBuddyCommand("\"Set :\(key) \"\(value)\"\"", for: file)
    }
    
    public static func save(file: File) throws {
        try self.runPlistBuddyCommand("Save", for: file)
    }
    
    public static func loadAsDictionary(file: File) throws -> [String: AnyHashable] {
        guard let data = FileManager.default.contents(atPath: file.path) else {
            throw PlistUpdater.Error.couldNotLoadData(path: file.path)
        }
        
        var plistFormat: PropertyListSerialization.PropertyListFormat = .xml
        let plist = try PropertyListSerialization.propertyList(from: data,
                                                               options: .mutableContainersAndLeaves,
                                                               format: &plistFormat)
        
        guard let plistDict = plist as? [String: AnyHashable] else {
            throw PlistUpdater.Error.couldNotTransformDataToDictionary(path: file.path)
        }
        
       return plistDict
    }
}
