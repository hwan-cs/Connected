//
//  DescriptiveData.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/11/16.
//

import Foundation

struct DescriptiveData: CustomStringConvertible, CustomDebugStringConvertible
{
    let data: Data
    let customDescription: String?
    
    init(data: Data, customDescription: String? = nil)
    {
        self.data = data
        self.customDescription = customDescription
    }
    
    var description: String { customDescription ?? data.description }
    var debugDescription: String { description }
}
