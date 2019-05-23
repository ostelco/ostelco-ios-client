//
//  GifVideo.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 5/23/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

/// Videos in mp4 fomrat that should loop like GIFs.
/// All videos should be placed in assets/gifMP4s.
/// TODO: Codegen this based on folder contents.
enum GifVideo: String, CaseIterable {
    case access
    case app
    case arrow_up
    case blank_canvas
    case heart
    case id
    case location
    case mail
    case no_connection
    case rocket
    case selfie
    case server_down
    case taken
    case time
    
    var url: URL {
        guard let url = Bundle.main.url(forResource: self.rawValue, withExtension: "mp4", subdirectory: "gifMP4s") else {
            fatalError("Couldn't get URL for video of gif \(self.rawValue)")
        }
        
        return url
    }
}
