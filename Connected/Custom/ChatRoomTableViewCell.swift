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
    
    @IBOutlet var onlineButton: UIButton!
    
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
