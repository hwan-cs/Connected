//
//  UniqueMessage.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/12/02.
//

import Foundation

struct UniqueMessage: Codable, Identifiable, Equatable
{
    var id = UUID().uuidString
    var data: Data?
}
