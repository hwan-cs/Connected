//
//  SignupViewController.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/09/13.
//

import Foundation
import UIKit
import TweeTextField
import PromiseKit
import FirebaseFirestore
import Combine

class SignupViewController: UIViewController, UIScrollViewDelegate
{
    @IBOutlet var idTextField: TweeBorderedTextField!
    
    @IBOutlet var emailTextField: TweeBorderedTextField!
    
    @IBOutlet var verifyTextField: TweeBorderedTextField!
    
    @IBOutlet var scrollView: UIScrollView!

    @IBOutlet var passwordTextField: [TweeBorderedTextField]!
    
    @IBOutlet var eyeImageVIew: [UIImageView]!
    
    var db = Firestore.firestore()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.hideKeyboard()
        idTextField.setUI()
        for ptf in passwordTextField
        {
            ptf.setUI()
            ptf.autocorrectionType = .no
        }
        emailTextField.setUI()
        verifyTextField.setUI()
        eyeImageVIew[0].tag = 10
        eyeImageVIew[1].tag = 20
        for eye in eyeImageVIew
        {
            eye.isUserInteractionEnabled = true
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapEyeImageView(tapGestureRecognizer:)))
            eye.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        scrollView.bounces = scrollView.contentOffset.y > 100
    }
    
    @objc func didTapEyeImageView(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        if tappedImage.tag % 10 == 0
        {
            passwordTextField[(tappedImage.tag/10)-1].isSecureTextEntry = false
            tappedImage.image = UIImage(systemName: "eye.slash")
            tappedImage.tag += 1
        }
        else
        {
            passwordTextField[(tappedImage.tag/10)-1].isSecureTextEntry = true
            tappedImage.image = UIImage(systemName: "eye")
            tappedImage.tag -= 1
        }
    }
    
    @IBAction func didTapDuplicateID(_ sender: UIButton)
    {
        Task.init
        {
            let flag = await self.findDuplicateID()
            if flag
            {
                print("Found")
            }
            else
            {
                print("Not found")
            }
        }
    }
    
    private func findDuplicateID() async -> Bool
    {
        do
        {
            let snapshotDocuments = try await db.collection("users").whereField("username", isNotEqualTo: false).getDocuments().documents
            for doc in snapshotDocuments
            {
                let data = doc.data()
                if let username = data["username"] as? String
                {
                    print(username)
                    if username == self.idTextField.text!
                    {
                        return true
                    }
                }
            }
        }
        catch
        {
            print(error)
        }
        return false
    }
}
