//
//  FriendRequestRTableViewCell.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/10/28.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class FriendRequestRTableViewCell: UITableViewCell
{
    @IBOutlet var friendRequestRProfileImage: UIImageView!
     
    @IBOutlet var friendRequestRFriendName: UILabel!
    
    @IBOutlet var acceptFriendRequestButton: UIButton!
    
    @IBOutlet var declineFriendRequestButton: UIButton!
    
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
    
    @IBAction func didTapAccept(_ sender: UIButton)
    {
        Task.init
        {
            if let received = try await self.db.collection("userInfo").document(self.myID!).getDocument().data()?["friendRequestR"] as? [String]
            {
                var temp = received
                temp.removeAll
                { el in
                    el == self.userID!
                }
                try await self.db.collection("userInfo").document(self.myID!).updateData(["friendRequestR" : temp])
            }
            if let sent = try await self.db.collection("userInfo").document(self.userID!).getDocument().data()?["friendRequestS"] as? [String]
            {
                var temp = sent
                temp.removeAll
                { el in
                    el == self.myID!
                }
                try await self.db.collection("userInfo").document(self.userID!).updateData(["friendRequestS" : temp])
            }
            if let friends = try await self.db.collection("userInfo").document(self.myID!).getDocument().data()?["friends"] as? [String]
            {
                var temp = friends
                temp.append(self.userID!)
                try await self.db.collection("userInfo").document(self.myID!).updateData(["friends" : temp])
            }
            if let rfriends = try await self.db.collection("userInfo").document(self.userID!).getDocument().data()?["friends"] as? [String]
            {
                var temp = rfriends
                temp.append(self.myID!)
                try await self.db.collection("userInfo").document(self.userID!).updateData(["friends" : temp])
            }
        }
    }
    
    @IBAction func didTapDecline(_ sender: UIButton)
    {
        Task.init
        {
            if let received = try await self.db.collection("userInfo").document(self.myID!).getDocument().data()?["friendRequestR"] as? [String]
            {
                var temp = received
                temp.removeAll
                { el in
                    el == self.userID!
                }
                try await self.db.collection("userInfo").document(self.myID!).updateData(["friendRequestR" : temp])
            }
            if let sent = try await self.db.collection("userInfo").document(self.userID!).getDocument().data()?["friendRequestS"] as? [String]
            {
                var temp = sent
                temp.removeAll
                { el in
                    el == self.myID!
                }
                try await self.db.collection("userInfo").document(self.userID!).updateData(["friendRequestS" : temp])
            }
        }
    }
}
