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
    @Persisted(primaryKey: true) var _id: ObjectId
    
    init(_id: ObjectId)
    {
        self._id = _id
    }
}
