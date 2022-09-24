//
//  ChatTableViewCell.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/09/21.
//

import UIKit
import DSWaveformImage

class ChatTableViewCell: UITableViewCell
{

    @IBOutlet var messageView: UIView!
    
    @IBOutlet var waveFormImageView: WaveformImageView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.messageView.clipsToBounds = true
        self.messageView.layer.masksToBounds = false
        self.waveFormImageView.contentMode = .scaleAspectFit
        self.contentView.layer.shadowRadius = 4
        self.contentView.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.contentView.layer.shadowColor = UIColor.gray.cgColor
        self.contentView.layer.shadowOpacity = 0.2
        

        self.messageView.roundCorners(topLeft: 24, topRight: 16, bottomLeft: 24, bottomRight: 0)
        
        let borderLayer = CAShapeLayer()
        borderLayer.path = (self.messageView.layer.mask! as! CAShapeLayer).path! // Reuse the Bezier path
        borderLayer.strokeColor = UIColor(red: 0.91, green: 0.92, blue: 0.94, alpha: 1.00).cgColor
        borderLayer.shadowRadius = 24
        borderLayer.shadowOffset = CGSize(width: 0, height: 8)
        borderLayer.shadowColor = UIColor.black.cgColor
        borderLayer.shadowOpacity = 0.2
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.lineWidth = 1
        borderLayer.frame = self.messageView.bounds
        self.messageView.layer.addSublayer(borderLayer)
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
