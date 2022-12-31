//
//  Message.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/12/30.
//

import Foundation
import RealmSwift

final class Chat: Object, Identifiable
{
    @Persisted var user: User? = nil
    @Persisted var otherUser: User? = nil
    
    @Persisted var messages = RealmSwift.List<String>()
    
    @Persisted var otherMessages = RealmSwift.List<String>()
    
    @Persisted(primaryKey: true) var _id: String
    
    convenience init(user: User? = nil, otherUser: User? = nil)
    {
        self.init()
        self.user = user
        self.otherUser = otherUser
        self._id = "\(user!._id)_\(otherUser!._id)"
    }
}

