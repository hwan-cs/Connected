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
        self.userInfoViewModel!.$friendsArray
            .debounce(for: 0.1, scheduler: RunLoop.main)
            .sink
            { (updatedArray:[String]) in
                self.friendsArray = updatedArray
                DispatchQueue.main.async
                {
                    self.tableView.reloadData()
                }
            }.store(in: &disposableBag)
    }
}
