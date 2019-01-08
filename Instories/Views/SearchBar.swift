//
//  SearchBar.swift
//  Instories
//
//  Created by Vladyslav Yakovlev on 06.04.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class SearchBar: UIView {
    
    var onCancelButtonTapped: (() -> ())?
    
    var onSearchFieldChangedText: (() -> ())?
    
    weak var searchFieldDelegate: UITextFieldDelegate? {
        didSet {
            searchField.delegate = searchFieldDelegate
        }
    }
    
    private let searchField: RoundTextField = {
        let textField = RoundTextField()
        textField.placeholder = "Search"
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .sentences
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        textField.font = Fonts.searchBarFont
        textField.frame.size.height = 46
        textField.backgroundColor = .white
        return textField
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame.size = CGSize(width: 50, height: 50)
        button.setImage(UIImage(named: "CloseIcon"), for: .normal)
        button.contentMode = .center
        return button
    }()
    
    var shadowColor = UIColor(hex: "D0021B") {
        didSet {
            searchField.layer.shadowColor = shadowColor.cgColor
        }
    }
    
    var shadowOpacity: Float = 0.08 {
        didSet {
            searchField.layer.shadowOpacity = shadowOpacity
        }
    }
    
    var autocapitalizationType: UITextAutocapitalizationType = .sentences {
        didSet {
            searchField.autocapitalizationType = autocapitalizationType
        }
    }
    
    var placeholder: String = "Search" {
        didSet {
            searchField.placeholder = placeholder
        }
    }
    
    var textAlignment: NSTextAlignment = .left {
        didSet {
            searchField.textAlignment = textAlignment
        }
    }
    
    var returnKeyType: UIReturnKeyType = .done {
        didSet {
            searchField.returnKeyType = returnKeyType
        }
    }
    
    var searchText: String {
        return searchField.text!
    }
    
    var showCancelButton = true {
        didSet {
            cancelButton.isHidden = !showCancelButton
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutViews()
    }
    
    private func setupViews() {
        backgroundColor = .white
        
        addSubview(searchField)
        addSubview(cancelButton)
        
        cancelButton.addTarget(self, action: #selector(tapCancelButton), for: .touchUpInside)
        
        searchField.addTarget(self, action: #selector(searchFieldChangedText), for: .editingChanged)
        searchField.addTarget(searchField, action: #selector(resignFirstResponder), for: .editingDidEndOnExit)
    }
    
    private func layoutViews() {
        cancelButton.center.y = frame.height/2
        cancelButton.frame.origin.x = frame.width - cancelButton.frame.width - 12
        
        searchField.frame.origin.x = 16
        searchField.frame.size.height = frame.height - 2*16
        searchField.center.y = frame.height/2
        if showCancelButton {
            searchField.frame.size.width = cancelButton.frame.minX - searchField.frame.minX - 10
        } else {
            searchField.frame.size.width = frame.width - searchField.frame.minX - 16
        }
    }
    
    @objc private func tapCancelButton() {
        onCancelButtonTapped?()
    }
    
    @objc private func searchFieldChangedText() {
        onSearchFieldChangedText?()
    }
    
    func makeTransparent() {
        backgroundColor = .clear
    }
    
    func makeOpaque(with color: UIColor) {
        backgroundColor = color
    }
    
    func showKeyboard() {
        UIView.animate(0.4, damping: 0.8, velocity: 0.8) {
            self.searchField.becomeFirstResponder()
        }
    }
    
    func hideKeyboard() {
        UIView.animate(0.24, options: .curveEaseOut) {
            self.searchField.resignFirstResponder()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
