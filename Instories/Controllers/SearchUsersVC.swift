//
//  SearchUsersVC.swift
//  Instories
//
//  Created by Vladyslav Yakovlev on 11/22/18.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

protocol SearchUsersDelegate: class {
    
    func userTapped(_ user: User)
}

final class SearchUsersVC: UIViewController {
    
    private var users = [User]()
    
    weak var delegate: SearchUsersDelegate?
    
    private let searchBar: SearchBar = {
        let searchBar = SearchBar()
        searchBar.shadowColor = .gray
        searchBar.showCancelButton = false
        searchBar.placeholder = "Username"
        searchBar.autocapitalizationType = .none
        searchBar.shadowOpacity = 0.12
        searchBar.textAlignment = .center
        return searchBar
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset.bottom = 20
        layout.minimumLineSpacing = 14
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    private lazy var alertView: AlertView = {
        let view = AlertView(frame: collectionView.bounds)
        view.text = "No users"
        return view
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
        
        view.addSubview(collectionView)
        view.addSubview(searchBar)
        
        searchBar.onSearchFieldChangedText = { [unowned self] in
            self.searchTextChanged()
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UserCell.self, forCellWithReuseIdentifier: UserCell.reuseId)
        
        setupKeyboardObserver()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.searchBar.showKeyboard()
        }
    }
    
    private func layoutViews() {
        searchBar.frame.origin.y = 0
        searchBar.frame.size = CGSize(width: view.frame.width - 50, height: 88)
        searchBar.center.x = view.center.x

        collectionView.frame.origin.y = searchBar.frame.maxY
        collectionView.frame.size.width = view.frame.width
        collectionView.center.x = searchBar.center.x
        collectionView.frame.size.height = view.frame.height - collectionView.frame.minY
        
        collectionView.contentInset.top = 18
        collectionView.scrollIndicatorInsets.top = collectionView.contentInset.top
    }
    
    private func searchTextChanged() {
        let text = searchBar.searchText.trimmingCharacters(in: .whitespaces).lowercased()
        
        guard !text.isEmpty else {
            users.removeAll()
            collectionView.backgroundView = nil
            reloadCollectionView()
            return
        }
        
        UserService.getUsers(with: text) { users in
            let currentText = self.searchBar.searchText.trimmingCharacters(in: .whitespaces).lowercased()
            guard !currentText.isEmpty, currentText == text else { return }
            self.users = users
            self.checkUsersCount()
            self.reloadCollectionView()
        }
    }
    
    private func checkUsersCount() {
        let count = users.count
        collectionView.backgroundView = count == 0 ? alertView : nil
    }
    
    private func reloadCollectionView() {
        collectionView.reloadSections(IndexSet(integer: 0))
    }
    
    deinit {
        removeKeyboardObserver()
    }
}

extension SearchUsersVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserCell.reuseId, for: indexPath) as! UserCell
        
        cell.tag += 1
        let tag = cell.tag
        
        let user = users[indexPath.item]
        cell.setUsername(user.username)
        if let avatarImage = user.avatarImage {
            cell.setAvatar(avatarImage) {
                cell.tag == tag
            }
        } else {
            URLSession.getImage(url: user.avatarUrl) { image in
                if let image = image {
                    user.avatarImage = image
                    if cell.tag == tag {
                        cell.setAvatar(image) {
                            cell.tag == tag
                        }
                    }
                }
            }
        }
        return cell
    }
}

extension SearchUsersVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = users[indexPath.item]
        delegate?.userTapped(user)
        searchBar.hideKeyboard()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 32, height: UIProperties.userCellHeight)
    }
}

extension SearchUsersVC {
    
    private func setupKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    private func removeKeyboardObserver() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc private func keyboardWillChangeFrame(notification: Notification) {
        let frame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue!
        if frame.origin.y >= view.frame.height {
            collectionView.contentInset.bottom = 0
            collectionView.scrollIndicatorInsets.bottom = collectionView.contentInset.bottom
        } else {
            collectionView.contentInset.bottom = frame.height
            collectionView.scrollIndicatorInsets.bottom = collectionView.contentInset.bottom
        }
    }
}
