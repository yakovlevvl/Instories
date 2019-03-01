//
//  UserCell.swift
//  Instories
//
//  Created by Vladyslav Yakovlev on 11/22/18.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class UserCell: UICollectionViewCell {
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.frame.size.height = 28
        label.font = Fonts.userCellFont
        return label
    }()
    
    private let avatarView: ImageView = {
        let imageView = ImageView()
        imageView.backgroundColor = Colors.avatarColor
        return imageView
    }()
    
    private let nextIcon: UIImageView = {
        let icon = UIImageView()
        icon.frame.size = CGSize(width: 30, height: 30)
        icon.image = UIImage(named: "NextSmall")
        icon.contentMode = .center
        return icon
    }()
    
    static let reuseId = "UserCell"
    
    var scaleByTap = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        layoutViews()
    }
    
    private func setupViews() {
        backgroundColor = .clear
        contentView.backgroundColor = .white

        contentView.addSubview(usernameLabel)
        contentView.addSubview(avatarView)
        contentView.addSubview(nextIcon)
    }
    
    private func layoutViews() {
        avatarView.frame.origin.x = 18
        avatarView.frame.size = CGSize(width: 50, height: 50)
        avatarView.center.y = contentView.center.y
        avatarView.layer.cornerRadius = avatarView.frame.height/2
        avatarView.clipsToBounds = true
        
        nextIcon.center.y = contentView.center.y
        nextIcon.frame.origin.x = contentView.frame.width - nextIcon.frame.width - 10
        
        usernameLabel.frame.origin.x = avatarView.frame.maxX + 18
        usernameLabel.center.y = contentView.center.y
        usernameLabel.frame.size.width = nextIcon.frame.minX - usernameLabel.frame.minX - 6
        
        contentView.makeCard(shadowOpacity: 0.12, shadowRadius: 15, shadowColor: .gray)
    }
    
    func setUsername(_ username: String) {
        usernameLabel.text = username
    }
    
    func setAvatar(_ image: UIImage?) {
        avatarView.image = image
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
