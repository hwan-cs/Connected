//
//  String_Extensions.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/09/17.
//

import Foundation

extension String
{
    var isValidEmail:Bool
    {
        return true
    }
    
    var isValidUsername: Bool
    {
        let usernameRegex = "^[a-zA-Z0-9]([._-](?![._-])|[a-zA-Z0-9]){3,18}[a-zA-Z0-9]$"
        return NSPredicate(format: "SELF MATCHES %@", usernameRegex).evaluate(with: self)
    }
    
    var isValidPassword: Bool
    {
        let passwordRegex = "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: self)
    }
}
