//
//  RecTextChatTableViewCell.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/09/30.
//

import UIKit

class RecTextChatTableViewCell: UITableViewCell
{
    @IBOutlet var messageView: UIView!
    
    @IBOutlet var myChatTextLabel: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.messageView.clipsToBounds = true
        self.messageView.layer.masksToBounds = false
        self.contentView.layer.shadowRadius = 4
        self.contentView.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.contentView.layer.shadowColor = UIColor.gray.cgColor
        self.contentView.layer.shadowOpacity = 0.2
        
        self.myChatTextLabel.font = UIFont.systemFont(ofSize: 16.0)
        self.messageView.layer.cornerRadius = 16.0
        self.messageView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
