//
//  ProfileSheetViewController.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/10/12.
//

import Foundation
import UIKit

class ProfileSheetViewController: UIViewController
{
    @IBOutlet var containerView: UIView!
    
    @IBOutlet var profileBackgroundImage: UIImageView!
    
    @IBOutlet var contentView: UIView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.profileBackgroundImage.layer.cornerRadius = 16.0
        self.profileBackgroundImage.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
}
