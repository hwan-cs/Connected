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
                        print("enter")
                        let name = try await self.db.collection("users").document(id).getDocument().data()!["name"] as? String
                        self.friends.append((id, name!))
                        print("leave")
                        dispatchGroup.leave()
                    }
                    self.sortedByValueDictionaryValue = updatedArray.sorted(by: { ($0.value[1] as! String) > ($1.value[1] as! String)}).map({$0.value})
                    
                    if updatedArray.count > 0
                    {
                        dispatchGroup.notify(queue: .main)
                        {
                            print("reloading data")
                            print(self.friends)
                            self.tableView.reloadData()
                        }
                    }
                }
            }.store(in: &disposableBag)
    }
}
