//
//  SettingsViewController.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/11/08.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.navigationController?.navigationBar.topItem?.title = "설정"
        self.navigationController?.navigationBar.backgroundColor = K.mainColor
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.safeAreaColorToMainColor()
    }
}
