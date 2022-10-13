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
    let defaultHeight: CGFloat = UIScreen.main.bounds.height * 0.6
    let maximumContainerHeight: CGFloat = UIScreen.main.bounds.height - 100
    // keep updated with new height
    var currentContainerHeight: CGFloat = UIScreen.main.bounds.height * 0.6
    
    var containerViewHeightConstraint: NSLayoutConstraint?
    
    var containerViewBottomConstraint: NSLayoutConstraint?
    
    @IBOutlet var containerView: UIView!
    
    @IBOutlet var profileBackgroundImage: UIImageView!
    
    @IBOutlet var contentView: UIView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
}
