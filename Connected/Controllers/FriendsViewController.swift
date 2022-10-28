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
        
        self.tableView.register(UINib(nibName: K.myProfileCellNibName, bundle: nil), forCellReuseIdentifier: K.myProfileCellID)
        self.tableView.register(UINib(nibName: K.friendProfileCellNibName, bundle: nil), forCellReuseIdentifier: K.friendProfileCellID)
        Task.init
        {
            try await self.db.collection("users").document(uuid!).updateData(["isOnline": true])
        }
        self.userInfoViewModel = UserInfoViewModel(uuid!)
        self.setBindings()
        presentTransition = CustomTransition()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.navigationController?.navigationBar.topItem?.title = "친구"
        self.navigationController?.navigationBar.backgroundColor = K.mainColor
        self.safeAreaColorToMainColor()
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "Add_Friend"), style: .plain, target: self, action: nil)
        barButtonItem.customView?.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        barButtonItem.tintColor = .black
        self.tabBarController?.navigationItem.rightBarButtonItem = barButtonItem
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.tableView.reloadData()
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ())
    {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    @objc func addFriend()
    {
        let alertController = UIAlertController(title: "비밀번호를 입력하세요", message: "^___^", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { alert -> Void in
            let textField = alertController.textFields![0] as UITextField
            if textField.text != "" && textField.text != self.uuid!
            {
                Task.init
                {
                    if let dict = try await self.db.collection("userInfo").document(self.uuid!).getDocument().data()?["friendRequestS"] as? [String]
                    {
                        var temp = dict
                        temp.append(textField.text!)
                        try await self.db.collection("userInfo").document(self.uuid!).updateData(["friendRequestS" : temp])
                        self.userInfoViewModel?.friendRequestS.append(textField.text!)
                    }
                    let doc = try await self.db.collection("users").whereField("username", isEqualTo: textField.text!).getDocuments()
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
                dispatchGroup.leave()
            }
        }
        else
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
}

extension FriendsViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let myProfileCell = tableView.dequeueReusableCell(withIdentifier: K.myProfileCellID) as! MyProfileTableViewCell
        let friendProfileCell = tableView.dequeueReusableCell(withIdentifier: K.friendProfileCellID) as! FriendProfileTableViewCell
        
        Task.init
        {
            let userID = indexPath.section == 0 ? self.uuid! : self.friendsArray[indexPath.row]
            let data = try await self.db.collection("users").document(userID).getDocument().data()
            if indexPath.section == 0
            {
                let storageRef = self.storage.reference()
                let myProfileRef = storageRef.child("\(self.uuid!)/ProfileInfo/")
                myProfileRef.listAll(completion:
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
                                if items.name.contains("profileImage")
                                {
                                    DispatchQueue.main.async
                                    {
                                        print("profile \(result.object)")
                                        myProfileCell.myProfileImage.image = UIImage(data: result.object)
                                        myProfileCell.myProfileImage.contentMode = .scaleAspectFit
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
                                        self.cacheStorage?.async.setObject(data!, forKey: items.name, completion: {_ in})
                                        if items.name.contains("profileImage")
                                        {
                                            DispatchQueue.main.async
                                            {
                                                myProfileCell.myProfileImage.image = UIImage(data: data!)
                                                myProfileCell.myProfileImage.contentMode = .scaleAspectFit
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
                myProfileCell.myProfileName.text = data!["name"] as? String
                myProfileCell.myProfileStatus.text = data!["statusMsg"] as? String
                myProfileCell.userID = data!["username"] as? String
            }
            else
            {
                friendProfileCell.friendName.text = data!["name"] as? String
                friendProfileCell.friendStatusMsg.text = data!["statusMsg"] as? String
                friendProfileCell.userID = data!["username"] as? String
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
                                        self.cacheStorage?.async.setObject(data!, forKey: items.name, completion: {_ in})
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
        return indexPath.section == 0 ? myProfileCell : friendProfileCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if section == 0
        {
            return 1
        }
        else if section == 1
        {
            return self.friendsArray.count
        }
        else if section == 2
        {
            return self.friendRequestS.count
        }
        else
        {
            return self.friendRequestR.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if section == 1
        {
            return "Friends \(self.friendsArray.count)"
        }
        else if section == 2
        {
            return "Friend Request Sent \(self.friendRequestS.count)"
        }
        else if section == 3
        {
            return "Friend Request Received \(self.friendRequestR.count)"
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
