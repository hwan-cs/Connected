//
//  ViewController.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/09/09.
//

import UIKit
import TweeTextField

class LoginViewController: UIViewController
{
    
    @IBOutlet var loginTextField: TweeBorderedTextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.hideKeyboard()
        loginTextField.layer.cornerRadius = 14
        loginTextField.layer.borderWidth = 1
        loginTextField.borderStyle = .none
        loginTextField.layer.borderColor = UIColor(red: 0.87, green: 0.89, blue: 0.91, alpha: 1.00).cgColor
        loginTextField.clipsToBounds = false
        loginTextField.addLeftPadding(value: 12.0)
        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        self.view.endEditing(true)
        return false
    }
}

