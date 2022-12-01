//
//  UniqueMessageIdentifier.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/12/02.
//

import Foundation

struct UniqueMessageIdentifier: Codable, Identifiable, Equatable
{
    var id = UUID().uuidString
    var isMe: Bool?
    var fileName: String?
}
