//
//  FriendsVC_Extensions.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/10/07.
//

import Foundation
import UIKit
import Cache

extension FriendsViewController
{
    func setBindings()
    {
        self.userInfoViewModel!.$friendsArray
            .debounce(for: 0.1, scheduler: RunLoop.main)
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
                    var idx = 0 
                    for el in self.friends
                    {
//                        self.db.collection("users").document(el.0).addSnapshotListener
//                        { documentSnapshot, error in
//                            guard documentSnapshot != nil
//                            else
//                            {
//                                print("Error fetching document: \(error)")
//                                return
//                            }
//                            guard self.tableView.cellForRow(at: IndexPath(row: self.friends.firstIndex(where: { a,b in
//                                a == el.0
//                            })!, section: 3)) is FriendProfileTableViewCell else { return }
//                            self.tableView.reloadRows(at: [IndexPath(row: self.friends.firstIndex(where: { a,b in
//                                a == el.0
//                            })!, section: 3)], with: .none)
//                        }
//                        self.tableView.reloadData()
                    }
                    self.tableView.reloadSections(IndexSet(integer: 3), with: .none)
                }
            }.store(in: &disposableBag)
        
        self.userInfoViewModel!.$friendRequestR
            .debounce(for: 0.1, scheduler: RunLoop.main)
            .sink
            { (updatedArray:[String]) in
                self.friendRequestR = updatedArray
                DispatchQueue.main.async
                {
                    self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
                }
            }.store(in: &disposableBag)
        
        self.userInfoViewModel!.$friendRequestS
            .debounce(for: 0.1, scheduler: RunLoop.main)
            .sink
            { (updatedArray:[String]) in
                self.friendRequestS = updatedArray
                DispatchQueue.main.async
                {
                    self.tableView.reloadSections(IndexSet(integer: 2), with: .automatic)
                }
            }.store(in: &disposableBag)
    }
}
