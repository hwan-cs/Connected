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
import FirebaseFirestore
import FirebaseAuth
import Firebase
import Cache

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
    
    var listener: ListenerRegistration?
    
    let storage = Storage.storage()
    
    let diskConfig = DiskConfig(name: "ChatRoomCache")
    
    let memoryConfig = MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10)
    
    lazy var cacheStorage: Cache.Storage<String, Data>? =
    {
        return try? Cache.Storage(diskConfig: diskConfig, memoryConfig: memoryConfig, transformer: TransformerFactory.forData())
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.hideKeyboard()
        self.tableView.register(UINib(nibName: K.chatRoomCellNibName, bundle: nil), forCellReuseIdentifier: K.chatRoomCellID)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.userInfoViewModel = UserInfoViewModel(uuid!)
        self.setBindings()
        
        listener = self.db.collection("userInfo").document(self.uuid!).addSnapshotListener(
        { documentSnapshot, error in
            guard documentSnapshot != nil
            else
            {
                print("Error fetching document: \(error!)")
                return
            }
            Task.init
            {
                if let data = documentSnapshot?.data()
                {
                    if let chatRooms = data["chatRoom"] as? [String:[Any]]
                    {
                        self.userInfoViewModel?.chatRoomArray = chatRooms
                        if self.chatRoomArray.count > 0  && self.friendsArray.count > 0
                        {
                            DispatchQueue.main.async
                            {
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.navigationController?.navigationBar.topItem?.title = "채팅"
        self.navigationController?.navigationBar.backgroundColor = K.mainColor
        self.safeAreaColorToMainColor()
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "NewChat"), style: .plain, target: self, action: #selector(onNewChatTap))
        barButtonItem.tintColor = .black
        self.tabBarController?.navigationItem.rightBarButtonItem = barButtonItem
        self.navigationController?.navigationBar.backgroundColor = .clear
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
//        self.tabBarController?.navigationItem.rightBarButtonItem = nil
    }
    
    @objc func onNewChatTap()
    {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewChatNavigationController") as! UINavigationController
        let nc = vc.children.first as! NewChatViewController
        nc.friendsArray = self.friendsArray
        nc.onDismissBlock =
        { success, rid in
            if success
            {
                let formatter = DateFormatter()
                formatter.timeZone = TimeZone.current
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                let now = formatter.string(from: Date.now)
                self.userInfoViewModel?.chatRoomArray[rid] = ["", now, 0]
                let cvc = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
                cvc.recepientUID = rid
                Task.init
                {
                    if let dict = try await self.db.collection("userInfo").document(self.uuid!).getDocument().data()?["chatRoom"] as? [String:[AnyHashable]]
                    {
                        var temp = dict
                        temp[rid] = ["",now,0]
                        try await self.db.collection("userInfo").document(self.uuid!).updateData(["chatRoom" : temp])
                    }
                    else
                    {
                        try await self.db.collection("userInfo").document(self.uuid!).updateData(["chatRoom" : [rid: ["", now, 0]]])
                    }
                    if let rdict = try await self.db.collection("userInfo").document(rid).getDocument().data()?["chatRoom"] as? [String:[AnyHashable]]
                    {
                        var temp = rdict
                        temp[rid] = ["",now,0]
                        try await self.db.collection("userInfo").document(rid).updateData(["chatRoom" :temp])
                    }
                    else
                    {
                        try await self.db.collection("userInfo").document(rid).updateData(["chatRoom" : [self.uuid! : ["", now, 0]]])
                    }
                }
                cvc.userViewModel = UserViewModel(self.uuid!, rid)
                cvc.setBindings()
                self.navigationController?.pushViewController(cvc, animated: true)
            }
        }
        vc.modalPresentationStyle = .pageSheet
        self.present(vc, animated: true)
    }
}

extension ChatRoomViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        print("selected at \(indexPath.row)")
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        vc.recepientUID = (self.sortedByValueDictionaryKey[indexPath.row])
        vc.userViewModel = UserViewModel(self.uuid!, self.sortedByValueDictionaryKey[indexPath.row])
        vc.setBindings()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 80.0
    }
}

extension ChatRoomViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let chatRoomCell = tableView.dequeueReusableCell(withIdentifier: K.chatRoomCellID, for: indexPath) as! ChatRoomTableViewCell
        Task.init
        {
            chatRoomCell.nameLabel.text = (try await self.db.collection("users").document(self.sortedByValueDictionaryKey[indexPath.row]).getDocument().data()!["name"] as! String)
            if let isOnline = (try await self.db.collection("users").document(self.sortedByValueDictionaryKey[indexPath.row]).getDocument().data()?["isOnline"] as? Bool)
            {
                chatRoomCell.onlineLabel.backgroundColor = isOnline ? K.mainColor : .lightGray
            }
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
        let storageRef = self.storage.reference()
        let friendProfileRef = storageRef.child("\(self.friendsArray[indexPath.row])/ProfileInfo/")
        friendProfileRef.listAll(completion:
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
                        let result = try self.cacheStorage!.entry(forKey: items.name)
                        // The video is cached.
                        DispatchQueue.main.async
                        {
                            chatRoomCell.friendChatRoomProfileImage.image = UIImage(data: result.object)
                            chatRoomCell.friendChatRoomProfileImage.contentMode = .scaleAspectFill
                        }
                    }
                    catch
                    {
                        //maxsize of image file is 30MB
                        items.getData(maxSize: 30*1024*1024)
                        { data, dError in
                            if let dError = dError
                            {
                                print(dError.localizedDescription)
                            }
                            else
                            {
                                self.cacheStorage?.async.setObject(data!, forKey: items.name, completion: {_ in})
                                chatRoomCell.friendChatRoomProfileImage.image = UIImage(data: data!)
                                chatRoomCell.friendChatRoomProfileImage.contentMode = .scaleAspectFill
                            }
                        }
                    }
                }
            }
        })
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let date = formatter.date(from: (self.sortedByValueDictionaryValue[indexPath.row][1] as! String))
        {
            let relativeFormatter = RelativeDateTimeFormatter()
            relativeFormatter.unitsStyle = .full
            chatRoomCell.timeLabel.text = relativeFormatter.localizedString(for: date, relativeTo: Date.now)
        }
        if let unreadCount = (self.sortedByValueDictionaryValue[indexPath.row][2] as? NSNumber)
        {
            if unreadCount.stringValue == "0"
            {
                chatRoomCell.unreadMessagesCount.isHidden = true
            }
            else
            {
                chatRoomCell.unreadMessagesCount.text = unreadCount.stringValue
                chatRoomCell.unreadMessagesCount.isHidden = false
            }
        }
        chatRoomCell.selectionStyle = .none
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
