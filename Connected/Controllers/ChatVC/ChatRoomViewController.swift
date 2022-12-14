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
import ESPullToRefresh
import Cache

class ChatRoomViewController: UIViewController
{
    @IBOutlet var tableView: UITableView!
    
    var userInfoViewModel: UserInfoViewModel?
    
    var disposableBag = Set<AnyCancellable>()
    
    var friendsArray: [String] = []
    
    var friendsNameArray: [String] = []
    
    var friends: [(String, String)] = []
    
    var chatRoomArray: [String:[Any]] = [:]
    
    var sortedByValueDictionaryKey: [String] = []
    
    static var sortedByValueDictionaryValue: [[Any?]] = [[]]
    
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
    
    @IBOutlet var searchBar: UISearchBar!
    
    var isFiltering = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.hideKeyboard()
        self.tableView.register(UINib(nibName: K.chatRoomCellNibName, bundle: nil), forCellReuseIdentifier: K.chatRoomCellID)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.searchBar.delegate = self
        self.userInfoViewModel = UserInfoViewModel(uuid!)
        self.setBindings()
        
        self.tableView.es.addPullToRefresh
        {
            self.tableView.reloadData()
            self.tableView.es.stopPullToRefresh()
        }
        
        self.db.collection("userInfo").document(self.uuid!).addSnapshotListener(
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
                    }
                }
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.navigationController?.navigationBar.topItem?.title = K.lang == "ko" ? "??????" : "Chat"
        self.navigationController?.navigationBar.backgroundColor = K.mainColor
        self.safeAreaColorToMainColor()
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "NewChat")?.withTintColor(UIColor(named: "BlackAndWhite")!), style: .plain, target: self, action: #selector(onNewChatTap))
        barButtonItem.tintColor = .black
        self.tabBarController?.navigationItem.rightBarButtonItem = barButtonItem
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.view.overrideUserInterfaceStyle = K.darkmode ? .dark : .light
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
        nc.chatArray = Array(self.chatRoomArray.keys)
        nc.onDismissBlock =
        { success, rid in
            if success
            {
                let formatter = DateFormatter()
                formatter.timeZone = TimeZone.current
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                let now = formatter.string(from: Date.now)
                self.userInfoViewModel?.chatRoomArray[rid] = ["", now, 0, false]
                let cvc = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
                cvc.recepientUID = rid
                Task.init
                {
                    if let dict = try await self.db.collection("userInfo").document(self.uuid!).getDocument().data()?["chatRoom"] as? [String:[AnyHashable]]
                    {
                        var temp = dict
                        temp[rid] = ["",now,0, false]
                        try await self.db.collection("userInfo").document(self.uuid!).updateData(["chatRoom" : temp])
                    }
                    else
                    {
                        try await self.db.collection("userInfo").document(self.uuid!).updateData(["chatRoom" : [rid: ["", now, 0, false]]])
                    }
                    if let rdict = try await self.db.collection("userInfo").document(rid).getDocument().data()?["chatRoom"] as? [String:[AnyHashable]]
                    {
                        var temp = rdict
                        temp[self.uuid!] = ["",now,0, false]
                        print("if")
                        try await self.db.collection("userInfo").document(rid).updateData(["chatRoom" :temp])
                    }
                    else
                    {
                        print("else")
                        try await self.db.collection("userInfo").document(rid).updateData(["chatRoom" : [self.uuid! : ["", now, 0, false]]])
                    }
                    cvc.userViewModel = UserViewModel(self.uuid!, rid)
                    cvc.isSharingLocation = false
                    cvc.setBindings()
                    self.navigationController?.pushViewController(cvc, animated: true)
                }
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
        vc.idx = indexPath.row
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
            chatRoomCell.nameLabel.text = self.friends[indexPath.row].1
            if let isOnline = (try await self.db.collection("users").document(self.sortedByValueDictionaryKey[indexPath.row]).getDocument().data()?["isOnline"] as? Bool)
            {
                chatRoomCell.onlineLabel.backgroundColor = isOnline ? .systemGreen : .lightGray
            }
        }
        if (ChatRoomViewController.sortedByValueDictionaryValue[indexPath.row][0] as! String) == "waveform"
        {
            let attString = NSMutableAttributedString(string:"")
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = UIImage(systemName: "waveform")?.withTintColor(UIColor(named: "BlackAndWhite")!)
            attString.append(NSAttributedString(attachment: imageAttachment))
            chatRoomCell.previewLabel.attributedText = attString
        }
        else
        {
            chatRoomCell.previewLabel.text = (ChatRoomViewController.sortedByValueDictionaryValue[indexPath.row][0] as! String)
        }
        let storageRef = self.storage.reference()
        let friendProfileRef = storageRef.child("\(self.sortedByValueDictionaryKey[indexPath.row])/ProfileInfo/")
        friendProfileRef.listAll(completion:
        { (storageListResult, error) in
            if let error = error
            {
                print(error.localizedDescription)
            }
            else
            {
                if storageListResult?.items.count == 0
                {
                    chatRoomCell.friendChatRoomProfileImage.image = UIImage(named: "Friend_Inactive")
                    chatRoomCell.friendChatRoomProfileImage.contentMode = .scaleAspectFill
                    return
                }
                for items in storageListResult!.items
                {
                    do
                    {
                        let result = try self.cacheStorage!.entry(forKey: "\(self.friends[indexPath.row].0)_\(items.name)")
                        if items.name.contains("profileImage")
                        {
                            let iv = chatRoomCell.friendChatRoomProfileImage
                            iv?.image = UIImage(data: result.object)
                            DispatchQueue.main.async
                            {
                                if chatRoomCell.friendChatRoomProfileImage.image?.pngData() != iv?.image?.pngData()
                                {
                                    chatRoomCell.friendChatRoomProfileImage.image = UIImage(data: result.object)
                                    chatRoomCell.friendChatRoomProfileImage.contentMode = .scaleAspectFill
                                }
                            }
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
                                if items.name.contains("profileImage")
                                {
                                    self.cacheStorage?.async.setObject(data!, forKey: "\(self.friends[indexPath.row].0)_\(items.name)", completion: {_ in})
                                    chatRoomCell.friendChatRoomProfileImage.image = UIImage(data: data!)
                                    chatRoomCell.friendChatRoomProfileImage.contentMode = .scaleAspectFill
                                }
                            }
                        }
                    }
                }
            }
        })
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let date = formatter.date(from: (ChatRoomViewController.sortedByValueDictionaryValue[indexPath.row][1] as! String))
        {
            let relativeFormatter = RelativeDateTimeFormatter()
            relativeFormatter.unitsStyle = .full
            chatRoomCell.timeLabel.text = relativeFormatter.localizedString(for: date, relativeTo: Date.now)
        }
        if let unreadCount = (ChatRoomViewController.sortedByValueDictionaryValue[indexPath.row][2] as? NSNumber)
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

extension ChatRoomViewController: UISearchBarDelegate
{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
        searchBar.showsCancelButton = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        self.dismissKeyboard()
                
        guard let text = searchBar.text?.lowercased() else { return }
        
        guard let searchTerm = searchBar.text, searchTerm.isEmpty == false else { return }
        
        K.searchFriends = self.friends
        K.searchChatRoomArray = self.chatRoomArray
        K.searchSortedByValueDictionaryValue = ChatRoomViewController.sortedByValueDictionaryValue
        K.searchSortedByValueDictionaryKey = self.sortedByValueDictionaryKey
        
        self.friends = self.friends.filter { $1.localizedCaseInsensitiveContains(text) }
        let foo = self.friends.compactMap({ a,b in a })
        
        self.chatRoomArray = self.chatRoomArray.filter { foo.contains($0.key) }
        
        self.sortedByValueDictionaryKey = self.chatRoomArray.sorted(by: { ($0.value[1] as! String)  > ($1.value[1] as! String)}).map({$0.key})
        ChatRoomViewController.sortedByValueDictionaryValue = self.chatRoomArray.sorted(by: { ($0.value[1] as! String) > ($1.value[1] as! String)}).map({$0.value})

        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        self.friends = K.searchFriends
        self.chatRoomArray = K.searchChatRoomArray
        self.sortedByValueDictionaryKey = K.searchSortedByValueDictionaryKey
        ChatRoomViewController.sortedByValueDictionaryValue = K.searchSortedByValueDictionaryValue
        self.tableView.reloadData()
    }
}
