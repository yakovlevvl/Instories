//
//  SettingCell.swift
//  Instories
//
//  Created by Vladyslav Yakovlev on 1/7/19.
//  Copyright © 2019 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class SettingCell: UICollectionViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.frame.size.height = 28
        label.font = Fonts.userCellFont
        return label
    }()
    
    private let nextIcon: UIImageView = {
        let icon = UIImageView()
        icon.frame.size = CGSize(width: 30, height: 30)
        icon.image = UIImage(named: "NextSmall")
        icon.contentMode = .center
        return icon
    }()
    
    static let reuseId = "SettingCell"
    
    var scaleByTap = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        layoutViews()
    }
    
    private func setupViews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(nextIcon)
        
        backgroundColor = .clear
        contentView.backgroundColor = .white
        
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        
        setupShadow()
    }
    
    private func layoutViews() {
        nextIcon.center.y = contentView.center.y
        nextIcon.frame.origin.x = contentView.frame.width - nextIcon.frame.width - 14
        
        titleLabel.center.y = contentView.center.y
        titleLabel.frame.origin.x = 30
        titleLabel.frame.size.width = nextIcon.frame.minX - titleLabel.frame.minX - 14
    }
    
    private func setupShadow() {
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
        layer.shadowOpacity = 0.12
        layer.shadowOffset = .zero
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowRadius = 15
    }
    
    func setupTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func setupTitleColor(_ color: UIColor) {
        titleLabel.textColor = color
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
