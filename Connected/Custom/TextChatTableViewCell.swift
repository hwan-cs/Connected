//
//  TextChatTableViewCell.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/09/29.
//

import UIKit

class TextChatTableViewCell: UITableViewCell
{

    @IBOutlet var messageView: UIView!
    
    @IBOutlet var myChatTextLabel: UILabel!
    
    @IBOutlet var timeLabel: UILabel!
    
    @IBOutlet var timeLabel_2: UILabel!
    
    var txtName: String!
    {
        didSet
        {
            let time = self.txtName.components(separatedBy: "T")
            self.timeLabel.text = time[0]
            self.timeLabel_2.text = String(time[1].prefix(5))
        }
    }
    
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
        self.messageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
