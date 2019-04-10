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
        try Secrets.run(sourceRoot: srcRootFolder, forProd: forProd)
    }
    
    public static func runPostBuild(sourceRootPath: String,
                                    forProd: Bool) throws {
        let srcRootFolder = try Folder(path: sourceRootPath)
        try Secrets.reset(sourceRoot: srcRootFolder)
    }
}
