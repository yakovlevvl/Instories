//
//  SettingsVC.swift
//  Instories
//
//  Created by Vladyslav Yakovlev on 08.03.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class SettingsVC: UIViewController {
    
    private enum Settings: String {
        
        case rateApp = "Rate app"
        
        case tellFriend = "Tell a friend"
        
        case sendFeedback = "Send feedback"
    }
    
    private let topBar: ClearTopBar = {
        let topBar = ClearTopBar()
        topBar.title = "Settings"
        topBar.includeLeftButton = true
        topBar.setLeftButtonImage(UIImage(named: "BackIcon"))
        topBar.titleFont = UIFont(name: Fonts.circeBold, size: 21)!
        return topBar
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset.bottom = 30
        layout.minimumLineSpacing = 14
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    private let settings: [Settings] = [.rateApp, .tellFriend, .sendFeedback]
    
    private let mailPresenter = MailControllerPresenter()
    
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
        
        view.addSubview(collectionView)
        view.addSubview(topBar)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SettingCell.self, forCellWithReuseIdentifier: SettingCell.reuseId)
        
        topBar.onLeftButtonTapped = { [unowned self] in
            self.tapBackButton()
        }
    }
    
    private func layoutViews() {
        topBar.frame.origin.x = 0
        topBar.frame.origin.y = currentDevice == .iPhoneX ? UIProperties.iPhoneXTopInset : 0
        topBar.frame.size = CGSize(width: view.frame.width, height: 84)
        
        collectionView.frame.origin = topBar.frame.origin
        collectionView.frame.size.width = view.frame.width
        collectionView.frame.size.height = view.frame.height - topBar.frame.minY
        
        collectionView.contentInset.top = topBar.frame.height + 2
        collectionView.scrollIndicatorInsets.top = collectionView.contentInset.top
    }
    
    private func tapBackButton() {
        navigationController?.popViewController(animated: true)
    }
}

extension SettingsVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return settings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingCell.reuseId, for: indexPath) as! SettingCell
        cell.setupTitle(settings[indexPath.item].rawValue)
        return cell
    }
}

extension SettingsVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let setting = settings[indexPath.item]
        didSelect(setting: setting)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 32, height: UIProperties.userCellHeight - 4)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > -scrollView.contentInset.top {
            topBar.makeOpaque(with: Colors.clearWhite)
        } else {
            topBar.makeTransparent()
        }
    }
}

extension SettingsVC {
    
    private func didSelect(setting: Settings) {
        switch setting {
        case .rateApp :
            RateAppService.openAppStore()
        case .tellFriend :
            showActivityController()
        case .sendFeedback :
            mailPresenter.present(from: self)
        }
    }
    
    private func showActivityController() {
        let appUrl = URL(string: "https://itunes.apple.com/app/\(AppInfo.appId)")!
        let text = "If you ever need to view Instagram stories anonymously, download this app \(appUrl)"
        let vc = UIActivityViewController(activityItems: [text], applicationActivities: [])
        present(vc, animated: true)
    }
}

