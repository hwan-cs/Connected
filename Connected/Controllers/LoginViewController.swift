//
//  ViewController.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/09/09.
//

import UIKit
import TweeTextField
import SwiftUI

class LoginViewController: UIViewController
{
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.backButtonTitle = "뒤로가기"
        self.navigationController?.navigationBar.tintColor = UIColor(red: 0.02, green: 0.78, blue: 0.51, alpha: 1.00)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginSheetViewController") as! LoginSheetViewController
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        self.view.endEditing(true)
        return false
    }
}

