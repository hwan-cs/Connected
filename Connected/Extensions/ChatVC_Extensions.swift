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
        self.userViewModel!.$audioArray.sink
        { (updatedArray:[Data]) in
            print("ChatVC - audioURL count: \(updatedArray.count)")
            self.audioArray = updatedArray
            DispatchQueue.main.async
            {
                self.tableView.reloadData()
            }
        }.store(in: &disposableBag)
    }
}

