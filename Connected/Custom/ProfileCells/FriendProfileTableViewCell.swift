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
    
    var myBackgroundImage: UIImage?
    
    var userID: String?
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.friendProfileImageView.layer.cornerRadius = 8.0
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        // Configure the view for the selected state
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        self.friendProfileImageView.image = UIImage(named: "Friend_Inactive")
    }
}
