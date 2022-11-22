//
//  UIView_Extensions.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/09/23.
//

import Foundation
import UIKit


extension UIView
{
    func roundCorners(topLeft: CGFloat = 0, topRight: CGFloat = 0, bottomLeft: CGFloat = 0, bottomRight: CGFloat = 0)
    {//(topLeft: CGFloat, topRight: CGFloat, bottomLeft: CGFloat, bottomRight: CGFloat) {
        let topLeftRadius = CGSize(width: topLeft, height: topLeft)
        let topRightRadius = CGSize(width: topRight, height: topRight)
        let bottomLeftRadius = CGSize(width: bottomLeft, height: bottomLeft)
        let bottomRightRadius = CGSize(width: bottomRight, height: bottomRight)
        let maskPath = UIBezierPath(shouldRoundRect: bounds, topLeftRadius: topLeftRadius, topRightRadius: topRightRadius, bottomLeftRadius: bottomLeftRadius, bottomRightRadius: bottomRightRadius)
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        layer.mask = shape
    }
    
    func scrollToBottom(animated: Bool)
    {
//        DispatchQueue.main.async
//        {
//            let point = CGPoint(x: 0, y: self.intrinsicContentSize.height + self.safeAreaInsets.bottom - self.frame.height)
//            if point.y >= 0
//            {
//                self.setContentOffset(point, animated: animated)
//            }
//        }
    }
}

extension CGRect {
    var minEdge: CGFloat {
        return min(width, height)
    }
}
