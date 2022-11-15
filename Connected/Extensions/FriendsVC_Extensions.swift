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
                        self.db.collection("users").document(el.0).addSnapshotListener
                        { documentSnapshot, error in
                            guard documentSnapshot != nil
                            else
                            {
                                print("Error fetching document: \(error)")
                                return
                            }
                            Task.init
                            {
                                let data = documentSnapshot?.data()!
                                guard let cell = self.tableView.cellForRow(at: IndexPath(row: self.friends.firstIndex(where: { a,b in
                                    a == el.0
                                })!, section: 3)) as? FriendProfileTableViewCell else { return }
                                cell.friendStatusMsg.text = data!["statusMsg"] as? String
                                cell.friendName.text = data!["name"] as? String
                                let storageRef = self.storage.reference()
                                let profileRef = storageRef.child("\(el.0)/ProfileInfo/")
                                profileRef.listAll(completion:
                                { (storageListResult, error) in
                                    if let error = error
                                    {
                                        print(error.localizedDescription)
                                    }
                                    else
                                    {
                                        for items in storageListResult!.items
                                        {
                                            do
                                            {
                                                let result = try self.cacheStorage!.entry(forKey: "\(el.0)_\(items.name)")
                                                if items.name.contains("profileImage")
                                                {
                                                    DispatchQueue.main.async
                                                    {
                                                        cell.friendProfileImageView.image = UIImage(data: result.object)
                                                        cell.friendProfileImageView.contentMode = .scaleAspectFill
                                                    }
                                                }
                                                else if items.name.contains("backgroundImage")
                                                {
                                                    cell.myBackgroundImage = UIImage(data: result.object)
                                                }
                                            }
                                            catch
                                            {
                                                print("no in cachestorage")
                                            }
                                        }
                                    }
                                })
                            }
                            print("dd")
                            self.tableView.reloadRows(at: [IndexPath(row: self.friends.firstIndex(where: { a,b in
                                a == el.0
                            })!, section: 3)], with: .none)
                        }
                        self.tableView.reloadData()
                    }
//                    self.tableView.reloadSections(IndexSet(integer: 3), with: .none)
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
