//
//  RoundButton.swift
//  Credits
//
//  Created by Vladyslav Yakovlev on 25.03.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit 

final class RoundButton: UIButton {
    
    var cornerRadius: CGFloat?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutViews()
    }
    
    private func setupViews() {
        contentMode = .center
        layer.shadowOffset = .zero
    }
    
    private func layoutViews() {
        layer.cornerRadius = cornerRadius ?? frame.height/2
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
    }
    
    func setImage(_ image: UIImage?) {
        setImage(image, for: .normal)
    }
    
    func setShadowOpacity(_ value: Float) {
        layer.shadowOpacity = value
    }
    
    func setShadowColor(_ color: UIColor) {
        layer.shadowColor = color.cgColor
    }
    
    func setShadowRadius(_ value: CGFloat) {
        layer.shadowRadius = value
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
