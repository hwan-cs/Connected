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
        self.userInfoViewModel!.$chatRoomArray.sink
        { (updatedArray:[String:[Any]]) in
            self.chatRoomArray = updatedArray
            self.sortedByValueDictionaryKey = updatedArray.sorted(by: { ($0.value[1] as! String)  > ($1.value[1] as! String)}).map({$0.key})
            self.sortedByValueDictionaryValue = updatedArray.sorted(by: { ($0.value[1] as! String) > ($1.value[1] as! String)}).map({$0.value})
            DispatchQueue.main.async
            {
                self.tableView.reloadData()
            }
        }.store(in: &disposableBag)
        
        self.userInfoViewModel!.$friendsArray.sink
        { (updatedArray:[String]) in
            self.friendsArray = updatedArray
            DispatchQueue.main.async
            {
                self.tableView.reloadData()
            }
        }.store(in: &disposableBag)
    }
}
