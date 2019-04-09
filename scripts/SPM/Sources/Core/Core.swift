//
//  Core.swift
//  Core
//
//  Created by Ellen Shapiro on 4/8/19.
//

import Files

public struct Core {
    
    public static func runPreBuild(sourceRootPath: String,
                                   forProd: Bool) throws {
        let srcRootFolder = try Folder(path: sourceRootPath)
        print("Root path: \(srcRootFolder.path)")
    }
    
    public static func runPostBuild(sourceRootPath: String,
                                    forProd: Bool) throws {
        let srcRootFolder = try Folder(path: sourceRootPath)

    }
}
