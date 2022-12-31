//
//  User.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/12/30.
//

import Foundation
import RealmSwift

final class User: Object, ObjectKeyIdentifiable
{
    @Persisted(primaryKey: true) var _id: String
    
    convenience init(_id: String)
    {
        self.init()
        self._id = _id
    }
}
