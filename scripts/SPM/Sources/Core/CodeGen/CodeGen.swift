//
//  CodeGen.swift
//  Basic
//
//  Created by Ellen Shapiro on 6/11/19.
//

import Files

struct CodeGen {
    
    static func run(sourceRoot: Folder) throws {
        try ImageGen.run(sourceRoot: sourceRoot)
    }
}
