//
//  UserViewModel.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/09/21.
//

import Foundation
import Combine

class UserViewModel: ObservableObject
{
    var userName: String?
    
    init()
    {
        print("User Viewmodel init")
    }
}
