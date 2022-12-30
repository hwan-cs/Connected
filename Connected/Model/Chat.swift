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
    
    init(user: User? = nil, otherUser: User? = nil)
    {
        self.user = user
        self.otherUser = otherUser
    }
}

