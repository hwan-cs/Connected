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
import Combine

class FriendsViewController: UIViewController
{
    @IBOutlet var tableView: UITableView!
    
    var userInfoViewModel: UserInfoViewModel?
    
    var disposableBag = Set<AnyCancellable>()
    
    var friendsArray: [String] = []
    
    var sortedByValueDictionaryKey: [String] = []
    
    var sortedByValueDictionaryValue: [[Any?]] = [[]]
    
    let uuid = Auth.auth().currentUser?.uid
    
    let db = Firestore.firestore()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = "친구"
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: K.myProfileCellNibName, bundle: nil), forCellReuseIdentifier: K.myProfileCellID)
        
        self.userInfoViewModel = UserInfoViewModel(uuid!)
        self.setBindings()
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ())
    {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
}

extension FriendsViewController: UITableViewDelegate
{
    
}

extension FriendsViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.myProfileCellID) as! MyProfileTableViewCell
        Task.init
        {
            let data = try await self.db.collection("users").document(self.uuid!).getDocument().data()
            cell.myProfileName.text = data!["name"] as? String
            
            self.getData(from: URL(string: "https://helios-i.mashable.com/imagery/articles/04i1KeWXNed98aQakEZjeOs/hero-image.fill.size_1248x702.v1623362896.jpg")!)
            { data, response, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async
                {
                    cell.myProfileImage.image = UIImage(data: data)
                    cell.myProfileImage.contentMode = .scaleAspectFit
                }
            }
            cell.myProfileStatus.text = "$sudo work"
        }
        if indexPath.section == 0
        {
            return cell
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if section == 0
        {
            return 1
        }
        else
        {
            //number of friends, to be fixed later
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 2
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
