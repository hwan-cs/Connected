//
//  NewChatViewController.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/11/04.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseAuth

class NewChatViewController: UIViewController
{
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var searchBar: UISearchBar!
    
    @IBOutlet var doneButton: UIBarButtonItem!
    
    var onDismissBlock : ((Bool, String) -> Void)?
    
    var friendsArray: [String] = []
    
    let db = Firestore.firestore()
    
    let uuid = Auth.auth().currentUser?.uid
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: K.friendProfileCellNibName, bundle: nil), forCellReuseIdentifier: K.friendProfileCellID)
        self.doneButton.tintColor = .lightGray
    }
    
    @IBAction func didTapNewChatDone(_ sender: UIBarButtonItem)
    {
        self.dismiss(animated: true)
        {
            self.onDismissBlock!(true, self.friendsArray[self.tableView.indexPathForSelectedRow!.row])
        }
    }
}

extension NewChatViewController: UITableViewDelegate
{
    
}

extension NewChatViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.friendProfileCellID, for: indexPath) as! FriendProfileTableViewCell
        Task.init
        {
            let data = try await self.db.collection("users").document(self.friendsArray[indexPath.row]).getDocument().data()
            cell.friendName.text = data!["name"] as? String
            cell.friendStatusMsg.text = data!["statusMsg"] as? String
            cell.userID = data!["username"] as? String
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.doneButton.tintColor = K.mainColor
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.friendsArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 64.0
    }
}
