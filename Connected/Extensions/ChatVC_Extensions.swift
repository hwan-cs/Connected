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
        
        self.userViewModel!.$userDataArray.sink
        { (updatedArray:[Data:[Any]]) in
            print("ChatVC - datarray count: \(updatedArray.count)")
            self.userDataArray = updatedArray
            //sort dictionary by name
            self.sortedByValueDictionaryKey = self.userDataArray.sorted(by: { ($0.value[1] as! String).components(separatedBy: ".")[0] < ($1.value[1] as! String).components(separatedBy: ".")[0]}).map({$0.key})
            self.sortedByValueDictionaryValue = self.userDataArray.sorted(by: { ($0.value[1] as! String).components(separatedBy: ".")[0] < ($1.value[1] as! String).components(separatedBy: ".")[0]}).map({$0.value})
            
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
            let indexPath = IndexPath(row: (self.userViewModel?.userDataArray.count ?? 1)-1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification)
    {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        {
            self.view.frame.origin.y -= keyboardSize.height
        }
    }

    @objc func keyboardWillHide(notification: NSNotification)
    {
        self.view.frame.origin.y = 0
    }

}
