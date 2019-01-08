//
//  MainVC.swift
//  Instories
//
//  Created by Vladyslav Yakovlev on 1/6/19.
//  Copyright © 2019 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class MainVC: UIViewController {
    
    private let searchUsersVC = SearchUsersVC()
    
    private let topBar: ClearTopBar = {
        let topBar = ClearTopBar()
        topBar.title = "Instories"
        topBar.includeRightButton = true
        topBar.setRightButtonImage(UIImage(named: "SettingsIcon"))
        topBar.titleFont = Fonts.topBar
        return topBar
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutViews()
    }

    private func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(topBar)
        addChildController(searchUsersVC)
        
        searchUsersVC.delegate = self
        
        topBar.onRightButtonTapped = { [unowned self] in
            self.settingsButtonTapped()
        }
    }
    
    private func layoutViews() {
        topBar.frame.origin.x = 0
        topBar.frame.origin.y = currentDevice == .iPhoneX ? UIProperties.iPhoneXTopInset : 0
        topBar.frame.size = CGSize(width: view.frame.width, height: 86)
        topBar.rightButtonCenterInset = -2
    
        searchUsersVC.view.frame.origin.x = 0
        searchUsersVC.view.frame.origin.y = topBar.frame.maxY - 10
        searchUsersVC.view.frame.size.width = view.frame.width
        searchUsersVC.view.frame.size.height = view.frame.height - searchUsersVC.view.frame.minY
    }
    
    private func settingsButtonTapped() {
        let settingsVC = SettingsVC()
        navigationController?.pushViewController(settingsVC, animated: true)
        view.endEditing(true)
    }
}

extension MainVC: SearchUsersDelegate {
    
    func userTapped(_ user: User) {
        let storiesVC = StoriesVC()
        storiesVC.user = user
        navigationController?.pushViewController(storiesVC, animated: true)
    }
}

