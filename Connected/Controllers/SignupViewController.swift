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
    @IBOutlet var idTextField: TweeAttributedTextField!
    
    @IBOutlet var emailTextField: TweeAttributedTextField!
    
    @IBOutlet var verifyTextField: TweeAttributedTextField!
    
    @IBOutlet var scrollView: UIScrollView!

    @IBOutlet var passwordTextField: [TweeAttributedTextField]!
    
    @IBOutlet var eyeImageVIew: [UIImageView]!
    
    var db = Firestore.firestore()
    
    let activityView = UIActivityIndicatorView(style: .medium)
    
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
                activityView.stopAnimating()
                idTextField.infoTextColor = .red
                idTextField.layer.borderColor = UIColor.red.cgColor
                idTextField.showInfo("중복된 아이디 입니다!", animated: true)
            }
            else
            {
                activityView.stopAnimating()
                idTextField.infoTextColor = UIColor(red: 0.02, green: 0.78, blue: 0.51, alpha: 1.00)
                idTextField.layer.borderColor = UIColor(red: 0.02, green: 0.78, blue: 0.51, alpha: 1.00).cgColor
                idTextField.showInfo("사용 가능한 아이디 입니다!", animated: true)
            }
        }
    }
    
    private func findDuplicateID() async -> Bool
    {
        do
        {
            idTextField.infoTextColor = .gray
            idTextField.showInfo("확인 중...", animated: true)
            scrollView.addSubview(activityView)
            activityView.leadingAnchor.constraint(equalTo: idTextField.infoLabel.leadingAnchor, constant: idTextField.infoLabel.intrinsicContentSize.width+4).isActive = true
            activityView.topAnchor.constraint(equalTo: idTextField.infoLabel.topAnchor).isActive = true
            activityView.heightAnchor.constraint(equalTo: idTextField.infoLabel.heightAnchor).isActive = true
            activityView.translatesAutoresizingMaskIntoConstraints = false
            activityView.startAnimating()
            
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
