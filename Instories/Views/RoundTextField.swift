//
//  RoundTextField.swift
//  Instories
//
//  Created by Vladyslav Yakovlev on 09.04.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class RoundTextField: UITextField {
    
    let padding = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutViews()
    }
    
    private func setupViews() {
        layer.cornerRadius = 16
        layer.shadowOpacity = 0.08
        layer.shadowOffset = .zero
        layer.shadowColor = UIColor(hex: "D0021B").cgColor
        layer.shadowRadius = 15
    }
    
    private func layoutViews() {
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.clearButtonRect(forBounds: bounds)
        rect.origin.x -= 8
        return rect
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
