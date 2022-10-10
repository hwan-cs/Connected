//
//  UIViewController_Extensions.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/09/12.
//

import Foundation
import UIKit

extension UIViewController
{
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func safeAreaColorToMainColor()
      {
         let mainColor = UIView()
         view.addSubview(mainColor)
          mainColor.translatesAutoresizingMaskIntoConstraints = false
          mainColor.backgroundColor = K.mainColor

         NSLayoutConstraint.activate([
            mainColor.topAnchor.constraint(equalTo: view.topAnchor),
            mainColor.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainColor.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])
      }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
    @objc func didTapEyeImageView(tapGestureRecognizer: UITapGestureRecognizer, textField: UITextField)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        if tappedImage.tag == 0
        {
            textField.isSecureTextEntry = false
            tappedImage.image = UIImage(systemName: "eye.slash")
            tappedImage.tag = 1
        }
        else
        {
            textField.isSecureTextEntry = true
            tappedImage.image = UIImage(systemName: "eye")
            tappedImage.tag = 0
        }
    }
}

