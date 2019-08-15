//
//  GifVideoGen.swift
//  Basic
//
//  Created by Ellen Shapiro on 6/11/19.
//

import Files

struct GifVideoGen {
    
    private static let videoPostfix = ".mp4"
    
    static func run(sourceRoot: Folder) throws {
        let appFolder = try sourceRoot.subfolder(named: "ostelco-ios-client")
        let assetsFolder = try appFolder.subfolder(named: "Assets")
        let gifMP4sFolder = try assetsFolder.subfolder(named: "gifMP4s")
        
        let boilerplate = try self.generateBoilerplate(from: gifMP4sFolder)
        
        let generatedCodeFolder = try appFolder.subfolder(named: "Generated")
        let targetFile = try generatedCodeFolder.file(named: "GifVideo.swift")
        
        try targetFile.write(string: boilerplate)
    }
    
    static func generateBoilerplate(from mp4Folder: Folder) throws -> String {
        
        let videos = mp4Folder.files
            .filter { $0.name.hasSuffix(self.videoPostfix) }
            .map { $0.name.replacingOccurrences(of: self.videoPostfix, with: "") }
        
        let cases = videos
            .map { "    case \($0)"}
            .joined(separator: "\n")
        
        let boilerplate = """
        /* This file is automatically generated. Don't try to edit it by hand! */
        
        import UIKit
        
        /// Videos in mp4 fomrat that should loop like GIFs.
        /// All videos should be placed in assets/gifMP4s.
        enum GifVideo: String, CaseIterable {
        \(cases)
        
            func url(for appearance: UIUserInterfaceStyle) -> URL {
                var filename = self.rawValue
                if appearance == .dark {
                    filename.append("_dark")
                }
                guard let url = Bundle.main.url(forResource: filename, withExtension: "mp4", subdirectory: "gifMP4s") else {
                    fatalError("Couldn't get URL for video of gif \\(filename)")
                }

                return url
            }
        }
        
        """
        
        return boilerplate
    }
}
