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
            .sink
            { (updatedArray:[String]) in
                self.friendsArray = updatedArray
                var foo = [String]()
                Task.init
                {
                    for id in self.friendsArray
                    {
                        let name = try await self.db.collection("users").document(id).getDocument().data()!["name"] as? String
                        foo.append(name!)
                    }
                    self.friendsNameArray = foo
                    let pair = Array(zip(self.friendsArray, self.friendsNameArray))
                    self.friends = pair.sorted { $0.1 < $1.1 }
                    print(self.friends)
                    DispatchQueue.main.async
                    {
                        self.tableView.reloadData()
                    }
                }
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
