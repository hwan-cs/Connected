//
//  UniqueMessageIdentifier.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/12/02.
//

import Foundation
import RealmSwift

class UniqueMessageIdentifier: Object, Codable, Identifiable
{
    @Persisted var id = UUID().uuidString
    @Persisted dynamic var isMe: Bool = true
    @Persisted dynamic var fileName: String = ""
    
    convenience init(id: String = UUID().uuidString, isMe: Bool, fileName: String)
    {
        self.init()
        self.id = id
        self.isMe = isMe
        self.fileName = fileName
    }
}
