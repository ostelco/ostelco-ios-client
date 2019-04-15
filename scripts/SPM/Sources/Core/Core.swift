//
//  Core.swift
//  Core
//
//  Created by Ellen Shapiro on 4/8/19.
//

import Files

public struct Core {
    
    /// Tasks which should be run prior to a build.
    ///
    /// - Parameters:
    ///   - sourceRootPath: The main iOS project's source root
    ///   - forProd: True if the production values should be used, false if the dev values should be used.
    public static func runPreBuild(sourceRootPath: String,
                                   forProd: Bool) throws {
        let srcRootFolder = try Folder(path: sourceRootPath)
        try Secrets.run(sourceRoot: srcRootFolder, forProd: forProd)
    }
    
    /// Tasks which should be run once the build has been completed.
    ///
    /// - Parameters:
    ///   - sourceRootPath: The main iOS project's source root
    ///   - forProd: True if the production values should be used, false if the dev values should be used.
    public static func runPostBuild(sourceRootPath: String,
                                    forProd: Bool) throws {
        let srcRootFolder = try Folder(path: sourceRootPath)
        try Secrets.reset(sourceRoot: srcRootFolder)
    }
}
