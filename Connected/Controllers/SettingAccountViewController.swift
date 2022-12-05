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
import FirebaseStorage
import UIKit

class SettingAccountViewController: UIViewController
{
    @IBOutlet var deleteAccountBtn: UIButton!
    
    let db = Firestore.firestore()
    
    let storage = Storage.storage()
    
    let uuid = Auth.auth().currentUser?.uid
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.safeAreaColorToMainColor()
        
        let backButton = UIImage(named: "backButton")
        self.navigationController?.navigationBar.tintColor = UIColor(named: "BlackAndWhite")!
        self.navigationController?.navigationBar.backIndicatorImage = backButton?.withTintColor(UIColor(named: "BlackAndWhite")!)
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = backButton?.withTintColor(UIColor(named: "BlackAndWhite")!)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.view.overrideUserInterfaceStyle = K.darkmode ? .dark : .light
        self.deleteAccountBtn.setTitle(K.lang == "ko" ? "계정 삭제" : "Delete Account", for: .normal)
    }
    
    @IBAction func didTapDeleteAcc(_ sender: UIButton)
    {
        let controller = UIAlertController.init(title: K.lang == "ko" ? "계정 삭제" : "Delete Account", message: K.lang == "ko" ? "계정을 삭제 하시겠습니까? 삭제된 계정은 다시 되돌릴 수 없습니다." : "Sure you want to delete this account? Deleted account cannot be brought back", preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: K.lang == "ko" ? "예" : "Yes", style: .default, handler:
        { _ in
            self.deleteUserInfo(user: self.uuid!)
            DispatchQueue.main.asyncAfter(deadline: .now()+5.0)
            {
                self.deleteAccount(user: self.uuid!)
            }
        }))
        controller.addAction(UIAlertAction(title: K.lang == "ko" ? "취소" : "Cancel", style: .cancel, handler: nil))
        self.present(controller, animated: true)
    }
    
    func deleteUserInfo(user: String)
    {
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
                                            print("Delete friend \(friend)")
                                        }
                                    }
                                }
                                if let chatRoom = data_["chatRoom"] as? [String: [Any]]
                                {
                                    var foo = chatRoom
                                    if foo.contains(where: { k, v in
                                        k == user
                                    })
                                    {
                                        foo.removeValue(forKey: user)
                                        Task.init
                                        {
                                            try await self.db.collection("userInfo").document(friend).updateData(["chatRoom" : foo])
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
    
    func deleteAccount(user: String)
    {
        Auth.auth().currentUser?.reauthenticate(with: EmailAuthProvider.credential(withEmail: K.myProfileEmail!, password: K.myProfilePassword!), completion:
        { authDataResult, error in
            if let error = error
            {
                print(error.localizedDescription)
            }
            else
            {
                Auth.auth().currentUser?.delete(completion:
                { (error) in
                    if let error = error
                    {
                        print(error.localizedDescription)
                    }
                    else
                    {
                        do
                        {
                            try Auth.auth().signOut()
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "InitialNavigationController") as! UINavigationController
                            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                            windowScene?.windows.first?.rootViewController = vc
                            windowScene?.windows.first?.makeKeyAndVisible()
                        }
                        catch
                        {
                            print("Could not sign out")
                        }
                    }
                })
            }
        })
        
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
        
        self.db.collection("userInfo").document(user).delete
        { error in
            if let error = error
            {
                print(error.localizedDescription)
            }
            else
            {
                print("Deleted \(user) from userInfo collection")
            }
        }
    }
}
