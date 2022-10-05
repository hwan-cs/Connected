//
//  UserInfoViewModel.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/10/05.
//

import Foundation
import UIKit
import Combine
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore


class UserInfoViewModel: ObservableObject
{
    @Published var friendsArray: [String] = []
    
    @Published var chatRoomArray: [String] = []
    
    let db = Firestore.firestore()
    
    init(_ uid: String)
    {
        Task.init
        {
            if let data = try await self.db.collection("userInfo").document(uid).getDocument().data()
            {
                if let friends = (data["friends"] as? [String])
                {
                    self.friendsArray = friends
                }
                if let chatRoom = (data["chatRoom"] as? [String])
                {
                    self.chatRoomArray = chatRoom
                }
            }
        }
    }
}
