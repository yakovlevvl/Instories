//
//  ProfileHeader.swift
//  Instories
//
//  Created by Vladyslav Yakovlev on 1/7/19.
//  Copyright © 2019 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class ProfileHeader: UICollectionReusableView {
    
    static let reuseId = "ProfileHeader"
    
    private let avatarView: ImageView = {
        let imageView = ImageView()
        imageView.backgroundColor = Colors.avatarColor
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: Fonts.circeBold, size: 21)!
        label.backgroundColor = .clear
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutViews()
    }
    
    private func setupViews() {
        backgroundColor = .clear
        
        addSubview(avatarView)
        addSubview(usernameLabel)
    }
    
    private func layoutViews() {
        avatarView.frame.origin.y = ProfileHeader.avatarTopInset
        avatarView.frame.size.width = ProfileHeader.avatarHeight
        avatarView.frame.size.height = ProfileHeader.avatarHeight
        avatarView.center.x = frame.width/2
        avatarView.layer.cornerRadius = avatarView.frame.height/2
        
        usernameLabel.frame.origin.y = avatarView.frame.maxY + ProfileHeader.usernameTopInset
        usernameLabel.frame.size.width = frame.width - 40
        usernameLabel.frame.size.height = ProfileHeader.usernameHeight
        usernameLabel.center.x = frame.width/2
    }
    
    func setAvatar(_ image: UIImage?) {
        avatarView.image = image
    }
    
    func setUsername(_ username: String) {
        usernameLabel.text = username
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ProfileHeader {
    
    static let avatarHeight: CGFloat = 100
    static let avatarTopInset: CGFloat = 6
    
    static let usernameHeight: CGFloat = 28
    static let usernameTopInset: CGFloat = 16
    static let usernameBottomInset: CGFloat = 16

    static var headerHeight: CGFloat {
        return avatarHeight + avatarTopInset + usernameTopInset +
            usernameHeight + usernameBottomInset
    }
}
