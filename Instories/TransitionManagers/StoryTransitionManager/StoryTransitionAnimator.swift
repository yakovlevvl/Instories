//
//  StoryTransitionAnimator.swift
//  Instories
//
//  Created by Vladyslav Yakovlev on 30.07.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

class StoryTransitionAnimator: NSObject {
    
    var presenting = true
    var presentDuration = 0.22
    var dismissDuration = 0.28
}

extension StoryTransitionAnimator: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return presenting ? presentDuration : dismissDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!
        let fromView = transitionContext.view(forKey: .from)!
        containerView.backgroundColor = .white
        
        if presenting {
            containerView.addSubview(toView)
        } else {
            containerView.insertSubview(toView, belowSubview: fromView)
        }
        
        if presenting {
            toView.alpha = 0
            UIView.animate(presentDuration, animation: {
                (transitionContext.viewController(forKey: .to) as? StoryVC)?.scaleUpImageView()
                toView.alpha = 1
            }, completion: { _ in
                transitionContext.completeTransition(true)
            })
        } else {
            UIView.animate(dismissDuration, animation: {
                fromView.alpha = 0
                //(transitionContext.viewController(forKey: .from) as? StoryVC)?.scaleDownImageView()
            }, completion: { _ in
                transitionContext.completeTransition(true)
            })
        }
    }
}

