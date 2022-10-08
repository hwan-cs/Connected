//
//  FriendsVC_Extensions.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/10/07.
//

import Foundation

extension FriendsViewController
{
    func setBindings()
    {
        self.userInfoViewModel!.$friendsArray.sink
        { (updatedArray:[String]) in
            self.friendsArray = updatedArray
        }.store(in: &disposableBag)
    }
}
