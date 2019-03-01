//
//  ImageView.swift
//  Instories
//
//  Created by Vladyslav Yakovlev on 19.08.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class ImageView: UIView {
    
    var image: UIImage? {
        didSet {
            drawImage(image)
        }
    }
    
    private let taskQueue = DispatchQueue(label: "com.wave.imageView", qos: .userInitiated, attributes: .concurrent)
    
    private var currentTask = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.disableAnimation()
        layer.contentsScale = UIScreen.main.scale
        layer.drawsAsynchronously = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let currentImage = image {
            drawImage(currentImage)
        }
    }
    
    private func drawImage(_ image: UIImage?) {
        currentTask += 1
        let task = currentTask
        
        guard let image = image else {
            layer.contents = nil
            return
        }
        
        let width = bounds.width*UIScreen.main.scale
        let height = bounds.height*UIScreen.main.scale
        
        if width == 0 || height == 0 {
            return
        }
        
        if image.size.width <= width, image.size.height <= height {
            layer.contents = image.cgImage
            return
        }
        
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        
        taskQueue.async {

            let context = CGContext(data: nil, width: Int(width), height: Int(height),
                                    bitsPerComponent: 8, bytesPerRow: Int(width)*4, space: CGColorSpaceCreateDeviceRGB(),
                                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
            
            context.draw(image.cgImage!, in: rect)
            
            let decodedImage = context.makeImage()!
            
            DispatchQueue.main.async {
                guard self.currentTask == task else { return }
                self.layer.contents = decodedImage
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

