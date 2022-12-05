//
//  SettingAccountViewController.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/12/05.
//

import Foundation
import FirebaseAuth
import Firebase
import FirebaseFirestore
import UIKit

class SettingAccountViewController: UIViewController
{
    let db = Firestore.firestore()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    func deleteUserInfo(user: String)
    {
        self.db.collection("users").document(user).delete
        { error in
            if let error = error
            {
                print(error.localizedDescription)
            }
            else
            {
                print("Deleted \(user) from users collection")
            }
        }

        Task.init
        {
            if let data = try await self.db.collection("userInfo").document(user).getDocument().data()
            {
                //Delete self from other user
                if let friends = (data["friends"] as? [String])
                {
                    for friend in friends
                    {
                        self.db.collection("userInfo").document(friend).getDocument
                        { documentSnapshot, error in
                            if let error = error
                            {
                                print(error.localizedDescription)
                            }
                            else
                            {
                                guard let data_ = documentSnapshot?.data() else { return }
                                if let fl = data_["friends"] as? [String]
                                {
                                    var foo = fl
                                    if foo.contains(user)
                                    {
                                        foo.remove(at: fl.firstIndex(of: user)!)
                                        Task.init
                                        {
                                            try await self.db.collection("userInfo").document(friend).updateData(["friends" : foo])
                                        }
                                    }
                                }
                                if let frrl = data_["friendRequestR"] as? [String]
                                {
                                    var foo = frrl
                                    if foo.contains(user)
                                    {
                                        foo.remove(at: frrl.firstIndex(of: user)!)
                                        Task.init
                                        {
                                            try await self.db.collection("userInfo").document(friend).updateData(["friendRequestR" : foo])
                                        }
                                    }
                                }
                                if let frsl = data_["friendRequestS"] as? [String]
                                {
                                    var foo = frsl
                                    if foo.contains(user)
                                    {
                                        foo.remove(at: frsl.firstIndex(of: user)!)
                                        Task.init
                                        {
                                            try await self.db.collection("userInfo").document(friend).updateData(["friendRequestS" : foo])
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                //Delete friendrequestS from other user
                if let friendRequestR = (data["friendRequestR"] as? [String])
                {
                    for friendR in friendRequestR
                    {
                        self.db.collection("userInfo").document(friendR).getDocument
                        { documentSnapshot, error in
                            if let error = error
                            {
                                print(error.localizedDescription)
                            }
                            else
                            {
                                guard let data_ = documentSnapshot?.data() else { return }
                                if let frsl = data_["friendRequestS"] as? [String]
                                {
                                    var foo = frsl
                                    if foo.contains(user)
                                    {
                                        foo.remove(at: frsl.firstIndex(of: user)!)
                                        Task.init
                                        {
                                            try await self.db.collection("userInfo").document(friendR).updateData(["friendRequestS" : foo])
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                //Delete friendrequestR from other user
                if let friendRequestS = (data["friendRequestS"] as? [String])
                {
                    for friendS in friendRequestS
                    {
                        self.db.collection("userInfo").document(friendS).getDocument
                        { documentSnapshot, error in
                            if let error = error
                            {
                                print(error.localizedDescription)
                            }
                            else
                            {
                                guard let data_ = documentSnapshot?.data() else { return }
                                if let frrl = data_["friendRequestR"] as? [String]
                                {
                                    var foo = frrl
                                    if foo.contains(user)
                                    {
                                        foo.remove(at: frrl.firstIndex(of: user)!)
                                        Task.init
                                        {
                                            try await self.db.collection("userInfo").document(friendS).updateData(["friendRequestR" : foo])
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func deleteAccount()
    {
        Auth.auth().currentUser?.delete(completion:
        { (error) in
            if let error = error
            {
                print(error.localizedDescription)
            }
            else
            {
                print("Successfully deleted account")
            }
        })
    }
}
