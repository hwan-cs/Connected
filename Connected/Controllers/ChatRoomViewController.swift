//
//  ChatRoomViewController.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/10/05.
//

import Foundation
import UIKit

class ChatRoomViewController: UIViewController
{
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.hideKeyboard()
        self.tableView.register(UINib(nibName: K.chatRoomCellNibName, bundle: nil), forCellReuseIdentifier: K.chatRoomCellID)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.navigationController?.navigationBar.topItem?.title = "채팅"
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "NewChat"), style: .plain, target: self, action: #selector(onNewChatTap))
        self.tabBarController?.navigationItem.rightBarButtonItem = barButtonItem
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
        return chatRoomCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 5
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {

    }
}
