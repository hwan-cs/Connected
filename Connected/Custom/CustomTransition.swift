//
//  CustomTransition.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/09/14.
//

import Foundation
import UIKit

class CustomTransition: NSObject, UIViewControllerAnimatedTransitioning
{
    let duration: TimeInterval = 0.125

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval
    {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning)
    {
        let container = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!

        container.addSubview(toView)
        toView.frame.origin = CGPoint(x: 0, y: toView.frame.height)

        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
            toView.frame.origin = CGPoint(x: 0, y: 0)
        }, completion: { _ in
            transitionContext.completeTransition(true)
        })
    }
}
