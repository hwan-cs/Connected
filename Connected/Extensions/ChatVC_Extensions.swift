//
//  ChatVC_Extensions.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/09/23.
//

import Foundation
import UIKit
import AVFoundation
import DSWaveformImage

//MARK: - ViewModel 관련
extension ChatViewController
{
    func setBindings()
    {
        print("ChatVC - setBindings()")
        
        self.userViewModel!.$dataName.sink
        { (updatedArray:[String]) in
            self.dataName = updatedArray
        }.store(in: &disposableBag)
        
        self.userViewModel!.$userDataArray.sink
        { (updatedArray:[Data:Bool]) in
            print("ChatVC - count: \(updatedArray.count)")
            self.userDataArray = updatedArray
            DispatchQueue.main.async
            {
                self.tableView.reloadData()
            }
        }.store(in: &disposableBag)
    }
    
    func scrollToBottom()
    {
        DispatchQueue.main.async
        {
            let indexPath = IndexPath(row: self.userDataArray.count-1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}
