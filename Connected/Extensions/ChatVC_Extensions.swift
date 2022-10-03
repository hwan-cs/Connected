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
    
    func initMapView()
    {
        let backgroundView = UIView()
        backgroundView.backgroundColor = K.mainColor
        backgroundView.layer.cornerRadius = 20
        NSLayoutConstraint.activate([
            backgroundView.heightAnchor.constraint(equalToConstant: 100.0),
            backgroundView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 8.0),
            backgroundView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 8.0),
            backgroundView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 8.0),
        ])
        backgroundView.addSubview(self.mapView)
        
        NSLayoutConstraint.activate([
            self.mapView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 8.0),
            self.mapView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 8.0),
            self.mapView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: 8.0),
            self.mapView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: 8.0)
        ])
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
