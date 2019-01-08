//
//  StoriesVC.swift
//  Instories
//
//  Created by Vladyslav Yakovlev on 1/7/19.
//  Copyright © 2019 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class StoriesVC: UIViewController {
    
    var user: User!
    
    private var stories = [Story]()
    
    private let topBar: ClearTopBar = {
        let topBar = ClearTopBar()
        topBar.title = "Stories"
        topBar.includeLeftButton = true
        topBar.setLeftButtonImage(UIImage(named: "BackIcon"))
        topBar.titleFont = UIFont(name: Fonts.circeBold, size: 21)!
        return topBar
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    private let indicator: UIImageView = {
        let indicator = UIImageView()
        indicator.image = UIImage(named: "Indicator")
        indicator.contentMode = .center
        return indicator
    }()
    
    private lazy var alertView: AlertView = {
        let view = AlertView(frame: collectionView.bounds)
        view.text = "No stories 😔"
        return view
    }()
    
    private let storyTransitionManager = StoryTransitionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        getStories()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(topBar)
        view.addSubview(collectionView)
        view.addSubview(indicator)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(StoryCell.self, forCellWithReuseIdentifier: StoryCell.reuseId)
        collectionView.register(ProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileHeader.reuseId)
        
        topBar.onLeftButtonTapped = { [unowned self] in
            self.backButtonTapped()
        }
    }
    
    private func layoutViews() {
        topBar.frame.origin.x = 0
        topBar.frame.origin.y = currentDevice == .iPhoneX ? UIProperties.iPhoneXTopInset : 0
        topBar.frame.size = CGSize(width: view.frame.width, height: 84)
    
        collectionView.frame.origin.x = 0
        collectionView.frame.size.width = view.frame.width
        collectionView.frame.origin.y = topBar.frame.maxY
        collectionView.frame.size.height = view.frame.height - collectionView.frame.minY
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        let ratio: CGFloat = 0.5625
        let space: CGFloat = 10
        let horizontalItemsCount: CGFloat = 3
        let spaceCount = horizontalItemsCount + CGFloat(1)
        let itemWidth = ((view.frame.width - spaceCount*space)/horizontalItemsCount).rounded(.down)
        let itemHeight = itemWidth/ratio
        
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.minimumLineSpacing = space
        layout.minimumInteritemSpacing = space
        layout.sectionInset = UIEdgeInsets(top: 18, left: space, bottom: space, right: space)
        layout.sectionInset.bottom = currentDevice == .iPhoneX ? 26 : space
        
        layout.headerReferenceSize.width = view.frame.width
        layout.headerReferenceSize.height = ProfileHeader.headerHeight
        
        indicator.frame.size = CGSize(width: 50, height: 50)
        indicator.center = view.center
    }
    
    private func getStories() {
        startIndicator()
        StoryService.getStories(for: user) { stories in
            self.stopIndicator()
            self.stories = stories
            self.checkStoriesCount()
            self.reloadCollectionView()
        }
    }
    
    private func checkStoriesCount() {
        let count = stories.count
        collectionView.backgroundView = count == 0 ? alertView : nil
    }
    
    private func reloadCollectionView() {
        collectionView.reloadSections(IndexSet(integer: 0))
    }
    
    private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension StoriesVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoryCell.reuseId, for: indexPath) as! StoryCell
        
        cell.tag += 1
        let tag = cell.tag
        
        let story = stories[indexPath.item]
        
        if let image = story.image {
            cell.setImage(image) {
                cell.tag == tag
            }
        } else {
            URLSession.getImage(url: story.imageUrl) { image in
                if let image = image {
                    story.image = image
                    if cell.tag == tag {
                        cell.setImage(image) {
                            cell.tag == tag
                        }
                    }
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileHeader.reuseId, for: indexPath) as! ProfileHeader
        view.setAvatar(user.avatarImage)
        view.setUsername(user.username)
        return view
    }
}

extension StoriesVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let story = stories[indexPath.item]
        let storyVC = StoryVC()
        storyVC.story = story
        storyVC.transitioningDelegate = storyTransitionManager
        present(storyVC, animated: true)
    }
}

extension StoriesVC {
    
    private func startIndicator() {
        let animate = CABasicAnimation(keyPath: "transform.rotation")
        animate.duration = 1
        animate.repeatCount = .infinity
        animate.fromValue = 0.0
        animate.toValue = 2.0 * Double.pi
        indicator.layer.add(animate, forKey: "")
        indicator.isHidden = false
    }
    
    private func stopIndicator() {
        indicator.layer.removeAllAnimations()
        indicator.isHidden = true
    }
}
