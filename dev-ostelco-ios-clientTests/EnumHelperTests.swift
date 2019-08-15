//
//  EnumHelperTests.swift
//  dev-ostelco-ios-clientTests
//
//  Created by Ellen Shapiro on 4/8/19.
//  Copyright © 2019 mac. All rights reserved.
//

@testable import Oya_Development_app
import XCTest

class EnumHelperTests: XCTestCase {
    
    func testAllStoryboardsInEnumExist() {
        for storyboard in Storyboard.allCases {
            XCTAssertNoThrow(storyboard.asUIStoryboard)
        }
    }
    
    func testAllExternalLinksCreateURLs() {
        for link in ExternalLink.allCases {
            XCTAssertNoThrow(link.url)
        }
    }
    
    func testAllGifVideosHaveActualFiles() {
        for video in GifVideo.allCases {
            XCTAssertTrue(FileManager.default.fileExists(atPath: video.url(for: .light).path), "File does not exist for \(video.rawValue)")
        }
        
        for video in GifVideo.allCases {
            XCTAssertTrue(FileManager.default.fileExists(atPath: video.url(for: .dark).path), "File does not exist for \(video.rawValue)")
        }
    }
    
    func testAllGifVideoFilesHaveEnumCases() {
        let folderContents = Bundle.main.paths(forResourcesOfType: "mp4", inDirectory: "gifMP4s")
        
        let fileNames = folderContents
            .map { ($0 as NSString).lastPathComponent }
            .map { ($0 as NSString).deletingPathExtension }
        
        XCTAssertEqual(fileNames.count, GifVideo.allCases.count)
        
        for fileName in fileNames {
            XCTAssertTrue(GifVideo.allCases.contains(where: { $0.rawValue == fileName }),
                          "Could not find enum case for \(fileName).mp4")
        }
    }
    
    func testAllImageAssetsCreateImages() {
        for asset in ImageAsset.allCases {
            XCTAssertNoThrow(UIImage(from: asset))
        }
    }
}
