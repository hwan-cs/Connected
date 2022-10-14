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
    
    var profileBg: UIImage?
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet var profileImage: UIImageView!
    
    var profileImg: UIImage?
    
    @IBOutlet var profileName: UILabel!
    
    var name: String?
    
    @IBOutlet var statusMessage: UILabel!
    
    var status: String?
    
    @IBOutlet var idLabel: UILabel!
    
    var id: String?
    
    @IBOutlet var editButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.profileImage.layer.cornerRadius = 16.0
        self.profileBackgroundImage.layer.masksToBounds = true
        self.profileBackgroundImage.layer.cornerRadius = 16.0
        self.profileBackgroundImage.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.profileBackgroundImage.layer.borderColor = UIColor.lightGray.cgColor
        self.profileBackgroundImage.layer.borderWidth = 0.5
//        self.containerView.sendSubviewToBack(self.profileImage)
        self.contentView.bringSubviewToFront(self.editButton)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        DispatchQueue.main.async
        {
            if let bg = self.profileBg
            {
                self.profileBackgroundImage.image = bg
            }
            self.profileImage.image = self.profileImg!
            self.statusMessage.text = self.status!
            self.idLabel.text = self.id!
        }
    }
}
