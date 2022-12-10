//
//  ChatRoomVC_Extensions.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/10/05.
//

import Foundation
import UIKit
import Combine
import Firebase

extension ChatRoomViewController
{
    func setBindings()
    {
        self.userInfoViewModel!.$friendsArray.sink
        { (updatedArray:[String]) in
            self.friendsArray = updatedArray
        }.store(in: &disposableBag)
        
        self.userInfoViewModel!.$chatRoomArray
            .debounce(for: 0.1, scheduler: RunLoop.main)
            .sink
            { (updatedArray:[String:[Any]]) in
                self.chatRoomArray = updatedArray
                self.sortedByValueDictionaryKey = updatedArray.sorted(by: { ($0.value[1] as! String)  > ($1.value[1] as! String)}).map({$0.key})
                
                let dispatchGroup = DispatchGroup()
                
                Task.init
                {
                    self.friends = []
                    for id in self.sortedByValueDictionaryKey
                    {
                        dispatchGroup.enter()
                        let name = try await self.db.collection("users").document(id).getDocument().data()!["name"] as? String
                        self.friends.append((id, name!))
                        dispatchGroup.leave()
                    }
                    ChatRoomViewController.sortedByValueDictionaryValue = updatedArray.sorted(by: { ($0.value[1] as! String) > ($1.value[1] as! String)}).map({$0.value})
                    
                    if updatedArray.count > 0
                    {
                        dispatchGroup.notify(queue: .main)
                        {
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
                                        guard let data = documentSnapshot?.data() else { return }
                                        let online = data["isOnline"] as! Bool
                                        UIView.performWithoutAnimation
                                        {
                                            if let cell = self.tableView.cellForRow(at: IndexPath(row: self.friends.firstIndex(where: { a,b in
                                                a == el.0
                                            })!, section: 0)) as? ChatRoomTableViewCell
                                            {
                                                cell.onlineLabel.backgroundColor = online ? .systemGray : .gray
//                                                self.tableView.reloadRows(at: [IndexPath(row: self.friends.firstIndex(where: { a,b in
//                                                    a == el.0
//                                                })!, section: 0)], with: .none)
                                                UIView.performWithoutAnimation
                                                {
                                                    self.tableView.reloadData()
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            if !K.didInitChatRoom
                            {
                                self.tableView.reloadData()
                                K.didInitChatRoom = true
                            }
                        }
                    }
                }
            }.store(in: &disposableBag)
    }
}
