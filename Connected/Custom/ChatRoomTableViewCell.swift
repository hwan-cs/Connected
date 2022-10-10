//
//  ChatRoomTableViewCell.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/10/05.
//

import UIKit

class ChatRoomTableViewCell: UITableViewCell
{
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var previewLabel: UILabel!
    
    @IBOutlet var timeLabel: UILabel!
    
    @IBOutlet var onlineLabel: UILabel!
    
    @IBOutlet var unreadMessagesCount: UILabel!
    
    @IBOutlet var friendChatRoomProfileImage: UIImageView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.friendChatRoomProfileImage.layer.cornerRadius = 8.0
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
