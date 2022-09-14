//
//  SignupViewController.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/09/13.
//

import Foundation
import UIKit
import TweeTextField

class SignupViewController: UIViewController, UIScrollViewDelegate
{
    @IBOutlet var idTextField: TweeBorderedTextField!
    
    @IBOutlet var emailTextField: TweeBorderedTextField!
    
    @IBOutlet var verifyTextField: TweeBorderedTextField!
    
    @IBOutlet var scrollView: UIScrollView!

    @IBOutlet var passwordTextField: TweeBorderedTextField!
    
    @IBOutlet var passwordReenterTextField: TweeBorderedTextField!
    
    @IBOutlet var eyeImageVIew: [UIImageView]!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.hideKeyboard()
        idTextField.setUI()
        passwordTextField.setUI()
        passwordReenterTextField.setUI()
        passwordTextField.autocorrectionType = .no
        passwordReenterTextField.autocorrectionType = .no
        emailTextField.setUI()
        verifyTextField.setUI()
        eyeImageVIew[0].tag = 10
        eyeImageVIew[1].tag = 20
        for eye in eyeImageVIew
        {
            eye.isUserInteractionEnabled = true
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapEyeImageView(tapGestureRecognizer:)))
            eye.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        scrollView.bounces = scrollView.contentOffset.y > 100
    }
    
    @objc func didTapEyeImageView(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        if tappedImage.tag % 10 == 0
        {
            if (tappedImage.tag/10)-1 == 0
            {
                passwordTextField.isSecureTextEntry = false
            }
            else
            {
                passwordReenterTextField.isSecureTextEntry = false
            }
            tappedImage.image = UIImage(systemName: "eye.slash")
            tappedImage.tag += 1
        }
        else
        {
            if (tappedImage.tag/10)-1 == 0
            {
                passwordTextField.isSecureTextEntry = true
            }
            else
            {
                passwordReenterTextField.isSecureTextEntry = true
            }
            tappedImage.image = UIImage(systemName: "eye")
            tappedImage.tag -= 1
        }
    }
}
