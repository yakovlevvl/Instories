//
//  ClearTopBar.swift
//  Instories
//
//  Created by Vladyslav Yakovlev on 22.02.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

class ClearTopBar: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.frame.size = CGSize(width: 120, height: 46)
        label.font = Fonts.topBar
        return label
    }()
    
    let leftButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame.size = CGSize(width: 50, height: 50)
        button.contentMode = .center
        return button
    }()
    
    let rightButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame.size = CGSize(width: 64, height: 50)
        button.setTitleColor(.gray, for: .disabled)
        return button
    }()
    
    var onLeftButtonTapped: (() -> ())?
    
    var onRightButtonTapped: (() -> ())?
    
    var roundLeftButton = false {
        didSet {
            if roundLeftButton {
                leftButton.layer.cornerRadius = leftButton.frame.height/2
            }
        }
    }
    
    var rightButtonCenterInset: CGFloat = 0
    
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
        
        addSubview(titleLabel)
        addSubview(leftButton)
        addSubview(rightButton)
        
        leftButton.addTarget(self, action: #selector(tapLeftButton), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(tapRightButton), for: .touchUpInside)
    }
    
    private func layoutViews() {
        let y = frame.height/2
        
        titleLabel.center.y = y
        
        leftButton.center.y = y
        leftButton.frame.origin.x = 16
        
        rightButton.center.y = y + rightButtonCenterInset
        rightButton.frame.origin.x = frame.width - rightButton.frame.width - 20
        
        titleLabel.frame.size.width = rightButton.frame.minX - leftButton.frame.maxX - 18
        titleLabel.center.x = frame.width/2
        
        if roundLeftButton {
            leftButton.layer.cornerRadius = leftButton.frame.height/2
        }
    }
    
    func makeTransparent() {
        backgroundColor = .clear
    }
    
    func makeOpaque(with color: UIColor) {
        backgroundColor = color
    }
    
    func hideTitle() {
        titleLabel.alpha = 0
        titleLabel.isHidden = true
    }
    
    func showTitle() {
        titleLabel.isHidden = false
        UIView.animate(0.15) {
            self.titleLabel.alpha = 1
        }
    }
    
    func hideRightButton() {
        rightButton.isHidden = true
    }
    
    func showRightButton() {
        rightButton.isHidden = false
    }
    
    func enableRightButton() {
        rightButton.isEnabled = true
    }
    
    func disableRightButton() {
        rightButton.isEnabled = false
    }
    
    @objc private func tapLeftButton() {
        onLeftButtonTapped?()
    }
    
    @objc private func tapRightButton() {
        onRightButtonTapped?()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ClearTopBar {
    
    var titleFont: UIFont {
        get { return titleLabel.font }
        set { titleLabel.font = newValue }
    }
    
    var title: String {
        get { return titleLabel.text ?? "" }
        set { titleLabel.text = newValue }
    }
    
    var includeRightButton: Bool {
        get { return !rightButton.isHidden }
        set { rightButton.isHidden = !newValue }
    }
    
    var includeLeftButton: Bool {
        get { return !leftButton.isHidden }
        set { leftButton.isHidden = !newValue }
    }
    
    func setLeftButtonImage(_ image: UIImage?) {
        leftButton.setImage(image, for: .normal)
    }
    
    func setLeftButtonColor(_ color: UIColor) {
        leftButton.backgroundColor = color
    }
    
    func setRightButtonImage(_ image: UIImage?) {
        rightButton.setImage(image, for: .normal)
        rightButton.frame.size = CGSize(width: 50, height: 50)
    }
    
    func setRightButtonTitle(_ title: String) {
        rightButton.setTitle(title, for: .normal)
        rightButton.frame.size = CGSize(width: 64, height: 50)
    }
    
    func setRightButtonTintColor(_ color: UIColor) {
        rightButton.tintColor = color
    }
    
    func setRightButtonTitleColor(_ color: UIColor) {
        rightButton.setTitleColor(color, for: .normal)
    }
    
    func setRightButtonFont(_ font: UIFont) {
        rightButton.titleLabel!.font = font
    }
}

