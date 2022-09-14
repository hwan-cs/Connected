//
//  SignupViewController.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/09/13.
//

import Foundation
import UIKit
import TweeTextField

class SignupViewController: UIViewController
{
    @IBOutlet var idTextField: TweeBorderedTextField!
    
    @IBOutlet var passwordTextField: TweeBorderedTextField!
    
    @IBOutlet var passwordReenterTextField: TweeBorderedTextField!
    
    @IBOutlet var emailTextField: TweeBorderedTextField!
    
    @IBOutlet var verifyTextField: TweeBorderedTextField!
    
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
    
    
}
