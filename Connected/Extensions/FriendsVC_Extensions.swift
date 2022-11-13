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
        self.userInfoViewModel!.$friendsNameArray
            .debounce(for: 0.1, scheduler: RunLoop.main)
            .sink
            { (updatedArray:[String]) in
                self.friendsNameArray = updatedArray.sorted()
                DispatchQueue.main.async
                {
                    self.tableView.reloadData()
                }
            }.store(in: &disposableBag)
        
        self.userInfoViewModel!.$friendsArray
            .sink
            { (updatedArray:[String]) in
                self.friendsArray = updatedArray
            }.store(in: &disposableBag)
        
        self.userInfoViewModel!.$friendRequestR
            .debounce(for: 0.1, scheduler: RunLoop.main)
            .sink
            { (updatedArray:[String]) in
                self.friendRequestR = updatedArray
                DispatchQueue.main.async
                {
                    self.tableView.reloadData()
                }
            }.store(in: &disposableBag)
        
        self.userInfoViewModel!.$friendRequestS
            .debounce(for: 0.1, scheduler: RunLoop.main)
            .sink
            { (updatedArray:[String]) in
                self.friendRequestS = updatedArray
                DispatchQueue.main.async
                {
                    self.tableView.reloadData()
                }
            }.store(in: &disposableBag)
    }
}
