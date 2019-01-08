//
//  Story.swift
//  Instories
//
//  Created by Vladyslav Yakovlev on 1/6/19.
//  Copyright © 2019 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class Story {
    
    let imageUrl: URL
    
    let videoUrl: URL?
    
    let timestamp: Int
    
    var image: UIImage?
    
    init(imageUrl: URL, timestamp: Int, videoUrl: URL?) {
        self.imageUrl = imageUrl
        self.timestamp = timestamp
        self.videoUrl = videoUrl
    }
}

