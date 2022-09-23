//
//  ChatVC_Extensions.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/09/23.
//

import Foundation
import UIKit
import AVFoundation

//MARK: - ViewModel 관련
extension ChatViewController
{
    func setBindings()
    {
        print("ChatVC - setBindings()")
        self.userViewModel.$audioURLArray.sink
        { (updatedArray:[String]) in
            print("ChatVC - audioURL count: \(updatedArray.count)")
            self.audioURLArray = updatedArray
            self.tableView.reloadData()
        }.store(in: &disposableBag)
    }
}
