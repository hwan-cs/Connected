//
//  RecTextChatTableViewCell.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/09/30.
//

import UIKit
import UIView_Shimmer
import AMPopTip

class RecTextChatTableViewCell: UITableViewCell, ShimmeringViewProtocol
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
            self.date = formatter.string(from: date!)
            formatter.dateFormat = K.lang == "ko" ? "MM월 dd일" : "MMMM dd"
            formatter.locale = Locale(identifier: K.lang)
            self.timeLabel.text = formatter.string(from: date!)
            self.timeLabel_2.text = String(time[1].prefix(5))
            formatter.dateFormat = "HH:mm:ssZ"
            self.time = formatter.string(from: formatter.date(from: time[1].components(separatedBy: ".")[0])!)
        }
    }
    
    var date: String?
    
    var time: String?
    
    let infoPopTip = PopTip()
    
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
        self.messageView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        self.messageView.layer.borderWidth = 0.5
        self.messageView.layer.borderColor = UIColor.lightGray.cgColor
        
        self.infoPopTip.bubbleColor = UIColor.gray
        self.infoPopTip.shouldDismissOnTap = true
        self.timeLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapTimeLabel(tapGestureRecognizer:))))
        self.timeLabel_2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapDateLabel(tapGestureRecognizer:))))
    }
    
    @objc func didTapTimeLabel(tapGestureRecognizer: UITapGestureRecognizer)
    {
        print("time")
        let lbl = tapGestureRecognizer.view as! UILabel
        if infoPopTip.isVisible
        {
            infoPopTip.hide()
        }
        infoPopTip.show(text: self.date!, direction: .right, maxWidth: 200, in: self.contentView, from: lbl.frame)
    }
    
    @objc func didTapDateLabel(tapGestureRecognizer: UITapGestureRecognizer)
    {
        print("date")
        let lbl = tapGestureRecognizer.view as! UILabel
        if infoPopTip.isVisible
        {
            infoPopTip.hide()
        }
        infoPopTip.show(text: self.time!, direction: .right, maxWidth: 200, in: self.contentView, from: lbl.frame)
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
