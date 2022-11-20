//
//  TextChatTableViewCell.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/09/29.
//

import UIKit
import UIView_Shimmer

class TextChatTableViewCell: UITableViewCell, ShimmeringViewProtocol
{

    @IBOutlet var messageView: UIView!
    
    @IBOutlet var myChatTextLabel: UILabel!
    
    @IBOutlet var timeLabel: UILabel!
    
    @IBOutlet var timeLabel_2: UILabel!
    
    let formatter = DateFormatter()
    
    var txtName: String!
    {
        didSet
        {
            let time = self.txtName.components(separatedBy: "T")
            formatter.dateFormat = "yyyy-MM-dd"
            let date = formatter.date(from: time[0])
            formatter.dateFormat = K.lang == "ko" ? "MM월 dd일" : "MMMM dd"
            formatter.locale = Locale(identifier: K.lang)
            self.timeLabel.text = formatter.string(from: date!)
            self.timeLabel_2.text = String(time[1].prefix(5))
        }
    }
    
    var shimmeringAnimatedItems: [UIView]
    {
        [
            messageView,
            myChatTextLabel,
            timeLabel,
            timeLabel_2
        ]
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        self.messageView.clipsToBounds = true
        self.messageView.layer.masksToBounds = false
        self.contentView.layer.shadowRadius = 2
        self.contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.contentView.layer.shadowColor = UIColor.gray.cgColor
        self.contentView.layer.shadowOpacity = 0.2
        
        self.myChatTextLabel.font = UIFont.systemFont(ofSize: 16.0)
        self.messageView.layer.cornerRadius = 16.0
        self.messageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
        self.messageView.layer.borderWidth = 0.5
        self.messageView.layer.borderColor = UIColor.lightGray.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
