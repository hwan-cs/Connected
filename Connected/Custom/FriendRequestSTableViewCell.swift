//
//  FriendRequestSTableViewCell.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/10/28.
//

import UIKit

class FriendRequestSTableViewCell: UITableViewCell
{

    @IBOutlet var friendRequestSProfileImage: UIImageView!
    
    @IBOutlet var friendRequestSFriendName: UILabel!
    
    var userID: String?
    
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
