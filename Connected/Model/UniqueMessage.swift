//
//  UniqueMessage.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/12/02.
//

import Foundation
import RealmSwift

class UniqueMessage: Object, Codable, Identifiable
{
    @Persisted dynamic var id = UUID().uuidString
    @Persisted dynamic var data: Data?
    
    convenience init(id: String = UUID().uuidString, data: Data? = nil)
    {
        self.init()
        self.id = id
        self.data = data
    }
}
