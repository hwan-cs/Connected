//
//  UIApplication_Extensions.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/09/14.
//

import Foundation
import UIKit

extension UIApplication
{
    class func topViewController(base: UIViewController? = UIApplication.shared.connectedScenes.flatMap({ ($0 as? UIWindowScene)?.windows ?? [] }).first{ $0.isKeyWindow }?.rootViewController) -> UIViewController?
    {
        if let nav = base as? UINavigationController
        {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController
        {
            if let selected = tab.selectedViewController
            {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController
        {
            return topViewController(base: presented)
        }
        return base
    }
}
