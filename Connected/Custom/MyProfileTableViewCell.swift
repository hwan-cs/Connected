//
//  MyProfileTableViewCell.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/10/07.
//

import UIKit

class MyProfileTableViewCell: UITableViewCell
{

    @IBOutlet var myProfileImage: UIImageView!
    
    @IBOutlet var myProfileName: UILabel!
    
    @IBOutlet var myProfileStatus: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
