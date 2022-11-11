//
//  SettingEtcViewController.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/11/11.
//

import Foundation
import UIKit

class SettingEtcViewController: UIViewController
{
    @IBOutlet var etcView: UIView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.safeAreaColorToMainColor()
        let backButton = UIImage(named: "backButton")
        self.navigationController?.navigationBar.tintColor = UIColor(named: "BlackAndWhite")!
        self.navigationController?.navigationBar.backIndicatorImage = backButton?.withTintColor(UIColor(named: "BlackAndWhite")!)
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = backButton?.withTintColor(UIColor(named: "BlackAndWhite")!)
        
        self.etcView.layer.borderColor = UIColor.lightGray.cgColor
        self.etcView.layer.borderWidth = 1
    }
}
