//
//  LoopingVideoView.swift
//  OstelcoStyles
//
//  Created by Ellen Shapiro on 5/22/19.
//  Copyright © 2019 mac. All rights reserved.
//

import AVFoundation
import UIKit

/// A view designed to play looping videos to look like GIFs
/// without the horrendous memory overhead of actual GIFs
@IBDesignable
public class LoopingVideoView: UIView {
    
    private lazy var gifPlayer = AVQueuePlayer()
    private lazy var playerLayer: AVPlayerLayer = {
        let playerLayer = AVPlayerLayer(player: self.gifPlayer)
        playerLayer.videoGravity = .resizeAspect
    
        // Get rid of doofy gray border on player layer
        playerLayer.shouldRasterize = true
        playerLayer.rasterizationScale = UIScreen.main.scale
        
        return playerLayer
    }()
    private(set) var playerLooper: AVPlayerLooper?
    
    // Note: This label only shows in Interface Builder so you can tell where the view will go.
    private lazy var ibPlaceholder: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Gif goes here!"
        
        return label
    }()
    
    /// The URL of the video to play. NOTE: Does not actually start playback.
    public var videoURL: URL? {
        didSet {
            guard let url = self.videoURL else {
                self.gifPlayer.pause()
                self.playerLooper = nil
                return
            }
            
            let playerItem = AVPlayerItem(url: url)
            self.playerLooper = AVPlayerLooper(player: self.gifPlayer, templateItem: playerItem)
        }
    }
    
    private func commonInit() {
        self.layer.addSublayer(self.playerLayer)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        guard self.ibPlaceholder.superview == nil else {
            // already set up
            return
        }
        
        self.backgroundColor = .lightGray
        self.addSubview(self.ibPlaceholder)

        self.addConstraints([
            self.ibPlaceholder.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.ibPlaceholder.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.playerLayer.frame = self.bounds
    }
    
    /// Starts playing the video on a loop
    public func play() {
        self.gifPlayer.play()
    }
    
    /// Pauses video playback
    public func pause() {
        self.gifPlayer.pause()
    }
}
