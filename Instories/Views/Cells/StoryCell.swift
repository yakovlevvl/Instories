//
//  StoryCell.swift
//  Instories
//
//  Created by Vladyslav Yakovlev on 1/7/19.
//  Copyright © 2019 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class StoryCell: UICollectionViewCell {
    
    static let reuseId = "StoryCell"
    
    private let imageView: ImageView = {
        let imageView = ImageView()
        imageView.backgroundColor = Colors.avatarColor
        return imageView
    }()
    
    var scaleByTap = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        layoutViews()
    }

    private func setupViews() {
        backgroundColor = .white
        
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true
        
        contentView.addSubview(imageView)
    }
    
    private func layoutViews() {
        imageView.frame = contentView.bounds
        makeCard(with: 10, shadowOpacity: 0.12, shadowRadius: 15, shadowColor: .gray)
    }
    
    func setImage(_ image: UIImage, finishHandler: @escaping () -> (Bool)) {
        imageView.drawImage(image) {
            finishHandler()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    override var isHighlighted: Bool {
        didSet {
            if !scaleByTap { return }
            if isHighlighted {
                UIView.animate(0.2) {
                    self.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
                    self.contentView.backgroundColor = UIColor(white: 1, alpha: 0.6)
                }
            } else {
                UIView.animate(0.4) {
                    self.transform = .identity
                    self.contentView.backgroundColor = .white
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
