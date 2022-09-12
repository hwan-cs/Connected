//
//  UITextField_Extensions.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/09/12.
//

import Foundation
import UIKit
import TweeTextField

extension UITextField
{
    func addLeftPadding(value: CGFloat)
    {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: value, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = ViewMode.always
    }
    
    func addRightPadding(value: CGFloat)
    {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: value, height: self.frame.height))
        self.rightView = paddingView
        self.rightViewMode = ViewMode.always
    }
}

extension TweeBorderedTextField
{
    func setUI()
    {
        self.layer.cornerRadius = 14
        self.layer.borderWidth = 1
        self.borderStyle = .none
        self.layer.borderColor = UIColor(red: 0.87, green: 0.89, blue: 0.91, alpha: 1.00).cgColor
        self.clipsToBounds = false
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect
    {
        let bounds = super.textRect(forBounds: bounds)
        return bounds.inset(by: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0))
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect
    {
        let bounds = super.placeholderRect(forBounds: bounds)
        return bounds.inset(by: UIEdgeInsets(top: 0, left: 8, bottom: 0, right:0))
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect
    {
        let bounds = super.editingRect(forBounds: bounds)
        return bounds.inset(by: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0))
    }
    
    override open func clearButtonRect(forBounds bounds: CGRect) -> CGRect
    {
        let originalRect = super.clearButtonRect(forBounds: bounds)
        return originalRect.offsetBy(dx: -50, dy: 0)
    }
}
