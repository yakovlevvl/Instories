//
//  StoryVC.swift
//  Instories
//
//  Created by Vladyslav Yakovlev on 1/7/19.
//  Copyright © 2019 Vladyslav Yakovlev. All rights reserved.
//

import UIKit
import AVFoundation

final class StoryVC: UIViewController {
    
    var story: Story!
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let closeButton: RoundButton = {
        let button = RoundButton(type: .custom)
        button.setImage(UIImage(named: "CloseIcon"))
        button.backgroundColor = UIColor(white: 1, alpha: 0.7)
        button.setShadowOpacity(0.26)
        button.setShadowColor(.gray)
        button.setShadowRadius(12)
        return button
    }()
    
    private var playerLayer: AVPlayerLayer?
    
    private var videoLooper: AVPlayerLooper?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .black
        
        view.addSubview(imageView)
        view.addSubview(closeButton)
        
        imageView.image = story.image
        
        scaleDownImageView()
        
        if let videoUrl = story.videoUrl {
            playerLayer = AVPlayerLayer()
            imageView.layer.addSublayer(playerLayer!)
            prepareForPlayingVideo(videoUrl)
            playVideo()
        }
        
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
    
    private func layoutViews() {
        imageView.frame = view.bounds
        playerLayer?.frame = imageView.bounds
        
        closeButton.frame.size = CGSize(width: 43, height: 43)
        closeButton.frame.origin.x = view.frame.width - closeButton.frame.width - 20
        closeButton.frame.origin.y = currentDevice == .iPhoneX ? 58 + UIProperties.iPhoneXTopInset : 20
    }
    
    func scaleUpImageView() {
        imageView.transform = .identity
    }
    
    func scaleDownImageView() {
        imageView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    private func prepareForPlayingVideo(_ videoUrl: URL) {
        let asset = AVAsset(url: videoUrl)
        let item = AVPlayerItem(asset: asset)
        
        let player = AVQueuePlayer(playerItem: item)
        player.automaticallyWaitsToMinimizeStalling = false
        videoLooper = AVPlayerLooper(player: player, templateItem: item)
        playerLayer!.player = player
    }
    
    private func playVideo() {
        playerLayer?.player?.play()
    }
}
