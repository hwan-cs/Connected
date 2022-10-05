//
//  ChatRoomViewController.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/10/05.
//

import Foundation
import UIKit
import Combine
import FirebaseStorage
import FirebaseAuth
import Firebase

class ChatRoomViewController: UIViewController
{
    @IBOutlet var tableView: UITableView!
    
    var userInfoViewModel: UserInfoViewModel?
    
    var disposableBag = Set<AnyCancellable>()
    
    var friendsArray: [String] = []
    
    var chatRoomArray: [String:[Any]] = [:]
    
    var sortedByValueDictionaryKey: [String] = []
    
    var sortedByValueDictionaryValue: [[Any?]] = [[]]
    
    let uuid = Auth.auth().currentUser?.uid
    
    let db = Firestore.firestore()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.hideKeyboard()
        self.tableView.register(UINib(nibName: K.chatRoomCellNibName, bundle: nil), forCellReuseIdentifier: K.chatRoomCellID)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.navigationController?.navigationBar.topItem?.title = "채팅"
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "NewChat"), style: .plain, target: self, action: #selector(onNewChatTap))
        barButtonItem.tintColor = K.mainColor
        self.tabBarController?.navigationItem.rightBarButtonItem = barButtonItem
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.userInfoViewModel = UserInfoViewModel(uuid!)
        self.setBindings()
    }
    
    @objc func onNewChatTap()
    {
        print("new chat tapped")
    }
}

extension ChatRoomViewController: UITableViewDelegate
{

}

extension ChatRoomViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let chatRoomCell = tableView.dequeueReusableCell(withIdentifier: K.chatRoomCellID, for: indexPath) as! ChatRoomTableViewCell
        Task.init
        {
            chatRoomCell.nameLabel.text = (try await self.db.collection("users").document(self.sortedByValueDictionaryKey[indexPath.row]).getDocument().data()!["name"] as! String)
        }
        if (self.sortedByValueDictionaryValue[indexPath.row][0] as! String) == "waveform"
        {
            let attString = NSMutableAttributedString(string:"")
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = UIImage(systemName: "waveform")
            attString.append(NSAttributedString(attachment: imageAttachment))
            chatRoomCell.previewLabel.attributedText = attString
        }
        else
        {
            chatRoomCell.previewLabel.text = (self.sortedByValueDictionaryValue[indexPath.row][0] as! String)
        }
        chatRoomCell.timeLabel.text = (self.sortedByValueDictionaryValue[indexPath.row][1] as! String)
        return chatRoomCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return chatRoomArray.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {

    }
}
