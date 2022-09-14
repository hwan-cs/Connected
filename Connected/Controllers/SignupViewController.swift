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
    
    @IBOutlet var passwordTextField: TweeBorderedTextField!
    
    @IBOutlet var passwordReenterTextField: TweeBorderedTextField!
    
    @IBOutlet var emailTextField: TweeBorderedTextField!
    
    @IBOutlet var verifyTextField: TweeBorderedTextField!
    
    @IBOutlet var scrollView: UIScrollView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.hideKeyboard()
        idTextField.setUI()
        passwordTextField.setUI()
        passwordReenterTextField.setUI()
        emailTextField.setUI()
        verifyTextField.setUI()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        scrollView.bounces = scrollView.contentOffset.y > 100
    }
}
