//
//  FriendProfileTableViewCell.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/10/08.
//

import UIKit

class FriendProfileTableViewCell: UITableViewCell
{

    @IBOutlet var friendProfileImageView: UIImageView!
    
    @IBOutlet var friendName: UILabel!
    
    @IBOutlet var friendStatusMsg: UILabel!
    
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
