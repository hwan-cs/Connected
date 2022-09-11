//
//  UITextField_Extensions.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/09/12.
//

import Foundation
import UIKit

extension UITextField
{
    func addLeftPadding(value: CGFloat)
    {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: value, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = ViewMode.always
    }
}
