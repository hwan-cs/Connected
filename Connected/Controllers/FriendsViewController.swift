//
//  FriendsViewController.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/10/07.
//

import Foundation
import UIKit
import VBRRollingPit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import Combine
import Cache
import SwiftMessages
import FirebaseMessaging
import UserNotifications
import FirebaseInstallations

class FriendsViewController: UIViewController
{
    @IBOutlet var tableView: UITableView!
    
    var userInfoViewModel: UserInfoViewModel?
    
    var disposableBag = Set<AnyCancellable>()
    
    var friendsArray: [String] = []
    
    var friendRequestR: [String] = []
    
    var friendRequestS: [String] = []
    
    var sortedByValueDictionaryKey: [String] = []
    
    var sortedByValueDictionaryValue: [[Any?]] = [[]]
    
    let uuid = Auth.auth().currentUser?.uid
    
    let db = Firestore.firestore()
    
    let diskConfig = DiskConfig(name: "FriendCache")
    
    let memoryConfig = MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10)
    
    lazy var cacheStorage: Cache.Storage<String, Data>? =
    {
        return try? Cache.Storage(diskConfig: diskConfig, memoryConfig: memoryConfig, transformer: TransformerFactory.forData())
    }()
    
    let storage = Storage.storage()
    
    var presentTransition: UIViewControllerAnimatedTransitioning?
    
    var backgroundImageToPass: UIImage?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.contentInsetAdjustmentBehavior = .never
        
        self.tableView.register(UINib(nibName: K.myProfileCellNibName, bundle: nil), forCellReuseIdentifier: K.myProfileCellID)
        self.tableView.register(UINib(nibName: K.friendProfileCellNibName, bundle: nil), forCellReuseIdentifier: K.friendProfileCellID)
        self.tableView.register(UINib(nibName: K.friendRequestRNibName, bundle: nil), forCellReuseIdentifier: K.friendRequestRCellID)
        self.tableView.register(UINib(nibName: K.friendRequestSNibName, bundle: nil), forCellReuseIdentifier: K.friendRequestSCellID)
        
        self.handleLogTokenTouch()
        
        Task.init
        {
            try await self.db.collection("users").document(uuid!).updateData(["isOnline": true])
        }
        self.userInfoViewModel = UserInfoViewModel(uuid!)
        self.setBindings()
        presentTransition = CustomTransition()
        
        self.db.collection("userInfo").document(self.uuid!).addSnapshotListener
        { documentSnapshot, error in
            guard documentSnapshot != nil
            else
            {
                print("Error fetching document: \(error!)")
                return
            }
            Task.init
            {
                print("change")
                if let data = try await self.db.collection("userInfo").document(self.uuid!).getDocument().data()
                {
                    self.userInfoViewModel?.friendRequestR = data["friendRequestR"] as! [String]
                    self.userInfoViewModel?.friendsArray = data["friends"] as! [String]
                    self.userInfoViewModel?.friendRequestS = data["friendRequestS"] as! [String]
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.navigationController?.navigationBar.topItem?.title = "친구"
        self.navigationController?.navigationBar.backgroundColor = K.mainColor
        self.safeAreaColorToMainColor()
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "Add_Friend"), style: .plain, target: self, action: #selector(addFriend))
        barButtonItem.customView?.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        barButtonItem.tintColor = .black
        self.tabBarController?.navigationItem.rightBarButtonItem = barButtonItem
        self.navigationController?.navigationBar.backgroundColor = .clear
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ())
    {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    @objc func addFriend()
    {
        //init swiftmessages
        let foobar = MessageView.viewFromNib(layout: .cardView)
        foobar.configureTheme(.error)
        let iconText = ["❓"].randomElement()!
        foobar.configureContent(title: "오류가 발생 했습니다!", body: "아이디를 다시 확인 해주세요", iconText: iconText)
        foobar.backgroundColor = .clear
        foobar.button?.setTitle("확인", for: .normal)
        foobar.buttonTapHandler =
        { _ in
            SwiftMessages.hide()
        }
        var fig = SwiftMessages.defaultConfig
        fig.duration = .automatic
        fig.shouldAutorotate = true
        fig.interactiveHide = true
        foobar.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20)
        
        let alertController = UIAlertController(title: "추가할 친구의 ID를 입력하세요", message: "", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { alert -> Void in
            let textField = alertController.textFields![0] as UITextField
            if textField.text != "" && textField.text != self.uuid!
            {
                Task.init
                {
                    let doc = try await self.db.collection("users").whereField("username", isEqualTo: textField.text!).getDocuments()
                    if doc.count == 0
                    {
                        self.dismiss(animated: true)
                        {
                            SwiftMessages.show(config: fig, view: foobar)
                        }
                        return
                    }
                    if let dict = try await self.db.collection("userInfo").document(self.uuid!).getDocument().data()?["friendRequestS"] as? [String], let dict2 = try await self.db.collection("userInfo").document(self.uuid!).getDocument().data()?["friends"] as? [String]
                    {
                        var temp = dict
                        var temp2 = dict2
                        if let data = doc.documents.first?.data()
                        {
                            let id = data["uid"] as! String
                            if temp.contains(id) || temp2.contains(id)
                            {
                                SwiftMessages.show(config: fig, view: foobar)
                                return
                            }
                            temp.append(id)
                            try await self.db.collection("userInfo").document(self.uuid!).updateData(["friendRequestS" : temp])
                        }
                    }
                    if let data = doc.documents.first?.data()
                    {
                        if let dict = try await self.db.collection("userInfo").document(data["uid"] as! String).getDocument().data()?["friendRequestR"] as? [String]
                        {
                            var temp = dict
                            temp.append(self.uuid!)
                            try await self.db.collection("userInfo").document(data["uid"] as! String).updateData(["friendRequestR" : temp])
                        }
                    }
                }
            }
        }))
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alertController.addTextField(configurationHandler: {(textField : UITextField!) -> Void in
            textField.placeholder = "아이디 입력"
        })
        self.present(alertController, animated: true, completion: nil)
    }
}

extension FriendsViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileSheetViewController") as! ProfileSheetViewController
        vc.modalPresentationStyle = .pageSheet
        vc.transitioningDelegate = self
        vc.onDismissBlock =
        { success in
            if success
            {
                DispatchQueue.main.async
                {
                    self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                    self.cacheStorage = try? Cache.Storage(diskConfig: self.diskConfig, memoryConfig: self.memoryConfig, transformer: TransformerFactory.forData())
                }
            }
        }
        let dispatchGroup = DispatchGroup()
        if indexPath.section == 0
        {
            dispatchGroup.enter()
            let cell = tableView.cellForRow(at: indexPath) as! MyProfileTableViewCell
            vc.profileImg = cell.myProfileImage.image
            if let bg = cell.myBackgroundImage
            {
                vc.profileBg = bg
            }
            vc.name = cell.myProfileName.text ?? "홍길동"
            vc.status = cell.myProfileStatus.text ?? "Hello World!"
            vc.id = cell.userID!
            vc.isEditable = true
            Task.init
            {
                let data = try await self.db.collection("users").document(self.uuid!).getDocument().data()
                vc.github = data!["github"] as? String
                vc.kakao = data!["kakao"] as? String
                vc.insta = data!["insta"] as? String
                vc.email = data!["email"] as? String
                dispatchGroup.leave()
            }
        }
        else if indexPath.section == 3
        {
            dispatchGroup.enter()
            let cell = tableView.cellForRow(at: indexPath) as! FriendProfileTableViewCell
            vc.profileImg = cell.friendProfileImageView.image
            if let bg = cell.myBackgroundImage
            {
                vc.profileBg = bg
            }
            vc.name = cell.friendName.text ?? "홍길동"
            vc.status = cell.friendStatusMsg.text ?? "Hello World!"
            vc.id = cell.userID!
            vc.isEditable = false
            Task.init
            {
                let data = try await self.db.collection("users").document(self.friendsArray[indexPath.row]).getDocument().data()
                vc.github = data!["github"] as? String
                vc.kakao = data!["kakao"] as? String
                vc.insta = data!["insta"] as? String
                vc.email = data!["email"] as? String
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main)
        {
            self.present(vc, animated: true, completion: { [weak self] in
                self?.presentTransition = nil
            })
        }
    }
    
    func handleLogTokenTouch()
    {
        let token = Messaging.messaging().fcmToken
        Task.init
        {
            if try await self.db.collection("users").document(uuid!).getDocument().data()!["fcmToken"] == nil
            {
                try await self.db.collection("users").document(uuid!).updateData(["fcmToken": token])
            }
        }
    }
}

extension FriendsViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let myProfileCell = tableView.dequeueReusableCell(withIdentifier: K.myProfileCellID) as! MyProfileTableViewCell
        let friendProfileCell = tableView.dequeueReusableCell(withIdentifier: K.friendProfileCellID) as! FriendProfileTableViewCell
        let friendRequestRCell = tableView.dequeueReusableCell(withIdentifier: K.friendRequestRCellID) as! FriendRequestRTableViewCell
        let friendRequestSCell = tableView.dequeueReusableCell(withIdentifier: K.friendRequestSCellID) as! FriendRequestSTableViewCell
        Task.init
        {
            var userID = ""
            if indexPath.section == 0
            {
                userID = self.uuid!
            }
            else if indexPath.section == 1
            {
                userID = friendRequestR[indexPath.row]
            }
            else if indexPath.section == 2
            {
                userID = friendRequestS[indexPath.row]
            }
            else if indexPath.section == 3
            {
                userID = self.friendsArray[indexPath.row]
            }
            let data = try await self.db.collection("users").document(userID).getDocument().data()
            let storageRef = self.storage.reference()
            let profileRef = storageRef.child("\(userID)/ProfileInfo/")
            if indexPath.section == 0
            {
                profileRef.listAll(completion:
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
                                let result = try self.cacheStorage!.entry(forKey: "\(userID)_\(items.name)")
                                if items.name.contains("profileImage")
                                {
                                    DispatchQueue.main.async
                                    {
                                        myProfileCell.myProfileImage.image = UIImage(data: result.object)
                                        myProfileCell.myProfileImage.contentMode = .scaleAspectFit
                                        K.myProfileImg = UIImage(data: result.object)
                                    }
                                }
                                else if items.name.contains("backgroundImage")
                                {
                                    myProfileCell.myBackgroundImage = UIImage(data: result.object)
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
                                        self.cacheStorage?.async.setObject(data!, forKey: "\(userID)_\(items.name)", completion: {_ in})
                                        if items.name.contains("profileImage")
                                        {
                                            DispatchQueue.main.async
                                            {
                                                myProfileCell.myProfileImage.image = UIImage(data: data!)
                                                myProfileCell.myProfileImage.contentMode = .scaleAspectFit
                                                K.myProfileImg = UIImage(data: data!)
                                            }
                                        }
                                        else if items.name.contains("backgroundImage")
                                        {
                                            myProfileCell.myBackgroundImage = UIImage(data: data!)
                                        }
                                    }
                                }
                            }
                        }
                    }
                })
                guard let name = data!["name"] as? String else { return }
                guard let username = data!["username"] as? String else { return }
                guard let email = data!["email"] as? String else { return }
                myProfileCell.myProfileName.text = name
                myProfileCell.myProfileStatus.text = data!["statusMsg"] as? String
                myProfileCell.userID = username
                K.myProfileName = name
                K.myProfileUsername = username
                K.myProfileEmail = email
            }
            //received friends requests
            else if indexPath.section == 1
            {
                profileRef.listAll(completion:
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
                                let result = try self.cacheStorage!.entry(forKey: "\(userID)_\(items.name)")
                                if items.name.contains("profileImage")
                                {
                                    DispatchQueue.main.async
                                    {
                                        print("profile \(result.object)")
                                        friendRequestRCell.friendRequestRProfileImage.image = UIImage(data: result.object)
                                        friendRequestRCell.friendRequestRProfileImage.contentMode = .scaleAspectFit
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
                                        self.cacheStorage?.async.setObject(data!, forKey: "\(userID)_\(items.name)", completion: {_ in})
                                        if items.name.contains("profileImage")
                                        {
                                            DispatchQueue.main.async
                                            {
                                                friendRequestRCell.friendRequestRProfileImage.image = UIImage(data: data!)
                                                friendRequestRCell.friendRequestRProfileImage.contentMode = .scaleAspectFit
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                })
                friendRequestRCell.friendRequestRProfileImage.isUserInteractionEnabled = false
                friendRequestRCell.myID = self.uuid!
                friendRequestRCell.friendRequestRFriendName.text = data!["name"] as? String
                friendRequestRCell.userID = data!["uid"] as? String
            }
            //sent friend request
            else if indexPath.section == 2
            {
                profileRef.listAll(completion:
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
                                let result = try self.cacheStorage!.entry(forKey: "\(userID)_\(items.name)")
                                if items.name.contains("profileImage")
                                {
                                    DispatchQueue.main.async
                                    {
                                        friendRequestSCell.friendRequestSProfileImage.image = UIImage(data: result.object)
                                        friendRequestSCell.friendRequestSProfileImage.contentMode = .scaleAspectFit
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
                                        self.cacheStorage?.async.setObject(data!, forKey: "\(userID)_\(items.name)", completion: {_ in})
                                        if items.name.contains("profileImage")
                                        {
                                            DispatchQueue.main.async
                                            {
                                                friendRequestSCell.friendRequestSProfileImage.image = UIImage(data: data!)
                                                friendRequestSCell.friendRequestSProfileImage.contentMode = .scaleAspectFit
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                })
                friendRequestSCell.isUserInteractionEnabled = false
                friendRequestSCell.myID = self.uuid!
                friendRequestSCell.friendRequestSFriendName.text = data!["name"] as? String
                friendRequestSCell.userID = data!["uid"] as? String
            }
            else if indexPath.section == 3
            {
                friendProfileCell.friendName.text = data!["name"] as? String
                friendProfileCell.friendStatusMsg.text = data!["statusMsg"] as? String
                friendProfileCell.userID = data!["username"] as? String
                profileRef.listAll(completion:
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
                                print("\(userID)_\(items.name)")
                                let result = try self.cacheStorage!.entry(forKey: "\(userID)_\(items.name)")
                                if items.name.contains("profileImage")
                                {
                                    DispatchQueue.main.async
                                    {
                                        friendProfileCell.friendProfileImageView.image = UIImage(data: result.object)
                                        friendProfileCell.friendProfileImageView.contentMode = .scaleAspectFit
                                    }
                                }
                                else if items.name.contains("backgroundImage")
                                {
                                    friendProfileCell.myBackgroundImage = UIImage(data: result.object)
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
                                        self.cacheStorage?.async.setObject(data!, forKey: "\(userID)_\(items.name)", completion: {_ in})
                                        if items.name.contains("profileImage")
                                        {
                                            DispatchQueue.main.async
                                            {
                                                friendProfileCell.friendProfileImageView.image = UIImage(data:  data!)
                                                friendProfileCell.friendProfileImageView.contentMode = .scaleAspectFit
                                            }
                                        }
                                        else if items.name.contains("backgroundImage")
                                        {
                                            friendProfileCell.myBackgroundImage = UIImage(data: data!)
                                        }
                                    }
                                }
                            }
                        }
                    }
                })
            }
        }
        myProfileCell.selectionStyle = .none
        friendProfileCell.selectionStyle = .none
        friendRequestSCell.selectionStyle = .none
        friendRequestRCell.selectionStyle = .none
        if indexPath.section == 0
        {
            return myProfileCell
        }
        else if indexPath.section == 1
        {
            return friendRequestRCell
        }
        else if indexPath.section == 2
        {
            return friendRequestSCell
        }
        return friendProfileCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if section == 0
        {
            return 1
        }
        else if section == 1
        {
            return self.friendRequestR.count
        }
        else if section == 2
        {
            return self.friendRequestS.count
        }
        else
        {
            return self.friendsArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if section == 1
        {
            return "받은 친구 요청 \(self.friendRequestR.count)"
        }
        else if section == 2
        {
            return "보낸 친구 요청 \(self.friendRequestS.count)"
        }
        else if section == 3
        {
            return "친구 \(self.friendsArray.count)"
        }
        return ""
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.section == 0
        {
            return 100.0
        }
        return 64.0
    }
}
