//
//  MyTabBarController.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/10/07.
//

import Foundation
import UIKit
import VBRRollingPit

class MyTabBarController: UITabBarController
{
    @IBOutlet var rollingPitTabBar: UITabBar!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        rollingPitTabBar.layer.shadowColor = UIColor.black.cgColor
        rollingPitTabBar.layer.shadowOffset = CGSize(width: 0, height: 10)
        rollingPitTabBar.layer.shadowOpacity = 0.2
        rollingPitTabBar.layer.shadowRadius = 20.0
    }
}
