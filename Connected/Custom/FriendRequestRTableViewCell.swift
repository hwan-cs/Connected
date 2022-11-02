//
//  FriendRequestRTableViewCell.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/10/28.
//

import UIKit

class FriendRequestRTableViewCell: UITableViewCell
{

    @IBOutlet var friendRequestRProfileImage: UIImageView!
    
    @IBOutlet var friendRequestRFriendName: UILabel!
    
    @IBOutlet var acceptFriendRequestButton: UIButton!
    
    @IBOutlet var declineFriendRequestButton: UIButton!
    
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
