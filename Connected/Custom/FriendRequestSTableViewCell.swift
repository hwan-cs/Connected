//
//  FriendRequestSTableViewCell.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/10/28.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class FriendRequestSTableViewCell: UITableViewCell
{

    @IBOutlet var friendRequestSProfileImage: UIImageView!
    
    @IBOutlet var friendRequestSFriendName: UILabel!
    
    let db = Firestore.firestore()
    
    var myID: String?
    
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
