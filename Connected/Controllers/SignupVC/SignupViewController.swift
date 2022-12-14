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
import FirebaseAuth
import Combine
import SwiftMessages
import AMPopTip

class SignupViewController: UIViewController, UIScrollViewDelegate, UITextFieldDelegate
{
    @IBOutlet var idTextField: TweeAttributedTextField!
    
    @IBOutlet var emailTextField: TweeAttributedTextField!
    
    @IBOutlet var scrollView: UIScrollView!

    @IBOutlet var passwordTextField: [TweeAttributedTextField]!
    
    @IBOutlet var eyeImageVIew: [UIImageView]!
    
    @IBOutlet var checkDuplicateButton: UIButton!
    
    @IBOutlet var nameTextField: TweeAttributedTextField!
    
    var db = Firestore.firestore()
    
    let activityView = UIActivityIndicatorView(style: .medium)
    
    let infoButton = UIButton()
    
    let pwInfoButton = UIButton()
    
    let infoPopTip = PopTip()
    
    var isDuplicateID = true
    
    @IBOutlet var signUpButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.hideKeyboard()
        idTextField.setUI()
        idTextField.delegate = self
        infoButton.tintColor = .systemGray
        infoButton.setImage(UIImage(systemName: "info.circle.fill"), for: .normal)
        infoButton.tag = 0
        nameTextField.setUI()
        nameTextField.delegate = self
        pwInfoButton.tintColor = .systemGray
        pwInfoButton.setImage(UIImage(systemName: "info.circle.fill"), for: .normal)
        pwInfoButton.tag = 1
        
        for ptf in passwordTextField
        {
            ptf.setUI()
            ptf.autocorrectionType = .no
            ptf.delegate = self
        }
        emailTextField.setUI()
        emailTextField.delegate = self
        //delegate self with nametextfield
        nameTextField.delegate = self
        eyeImageVIew[0].tag = 10
        eyeImageVIew[1].tag = 20
        for eye in eyeImageVIew
        {
            eye.isUserInteractionEnabled = true
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapEyeImageView(tapGestureRecognizer:)))
            eye.addGestureRecognizer(tapGestureRecognizer)
        }
        
        signUpButton.isUserInteractionEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.idTextField.tweePlaceholder = K.lang == "ko" ? "?????????" : "ID"
        self.passwordTextField[0].tweePlaceholder = K.lang == "ko" ? "????????????" : "Password"
        self.passwordTextField[1].tweePlaceholder = K.lang == "ko" ? "???????????? ?????????" : "Re-enter password"
        self.emailTextField.tweePlaceholder = K.lang == "ko" ? "?????????" : "Email"
        self.nameTextField.tweePlaceholder = K.lang == "ko" ? "??????" : "Name"
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
            self.isDuplicateID = await self.findDuplicateID()
            if self.isDuplicateID
            {
                activityView.stopAnimating()
                idTextField.infoTextColor = .red
                idTextField.layer.borderColor = UIColor.red.cgColor
                idTextField.showInfo(K.lang == "ko" ? "????????? ????????? ?????????!" : "Duplicate ID!", animated: true)
            }
            else
            {
                activityView.stopAnimating()
                idTextField.infoTextColor = UIColor(red: 0.02, green: 0.78, blue: 0.51, alpha: 1.00)
                idTextField.layer.borderColor = UIColor(red: 0.02, green: 0.78, blue: 0.51, alpha: 1.00).cgColor
                idTextField.showInfo(K.lang == "ko" ? "?????? ????????? ????????? ?????????!" : "Valid ID!", animated: true)
            }
        }
    }
    
    private func findDuplicateID() async -> Bool
    {
        do
        {
            idTextField.infoTextColor = .gray
            idTextField.showInfo(K.lang == "ko" ? "?????? ???..." : "Checking...", animated: true)
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
    
    @IBAction func idTextFieldDidChange(_ sender: TweeAttributedTextField)
    {
        if sender.layer.borderColor != UIColor(red: 0.87, green: 0.89, blue: 0.91, alpha: 1.00).cgColor
        {
            sender.layer.borderColor = UIColor(red: 0.87, green: 0.89, blue: 0.91, alpha: 1.00).cgColor
        }
        if let userInput = sender.text
        {
            if userInput.isValidUsername
            {
                checkDuplicateButton.titleLabel?.textColor = UIColor(red: 0.02, green: 0.78, blue: 0.51, alpha: 1.00)
                checkDuplicateButton.tintColor = UIColor(red: 0.02, green: 0.78, blue: 0.51, alpha: 1.00)
                checkDuplicateButton.isUserInteractionEnabled = true
                idTextField.infoTextColor = K.mainColor
                idTextField.showInfo(K.lang == "ko" ? "????????? ?????? ????????? ?????????" : "Valid username")
                self.infoButton.removeFromSuperview()
            }
            else
            {
                checkDuplicateButton.titleLabel?.textColor = .gray
                checkDuplicateButton.tintColor = .gray
                checkDuplicateButton.isUserInteractionEnabled = false
                idTextField.infoTextColor = .red
                let paragraph = NSMutableParagraphStyle()
                paragraph.tabStops = [
                    NSTextTab(textAlignment: .right, location: CGFloat(idTextField.infoLabel.frame.width-30), options: [:]),
                ]
                let attrString = NSMutableAttributedString(
                    string: K.lang == "ko" ? "????????? ?????? ????????????\t????????? ?????????? " : "Not a valid username\tWhat's a valid username?",
                    attributes: [NSAttributedString.Key.paragraphStyle: paragraph]
                )
                attrString.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.gray], range: NSRange(location: 12, length: 8))
                idTextField.showInfo(attrString)
                if !self.scrollView.subviews.contains(infoButton)
                {
                    self.scrollView.addSubview(self.infoButton)
                }
                infoButton.leadingAnchor.constraint(equalTo: idTextField.infoLabel.leadingAnchor, constant: idTextField.infoLabel.intrinsicContentSize.width+4).isActive = true
                infoButton.topAnchor.constraint(equalTo: idTextField.infoLabel.topAnchor).isActive = true
                infoButton.heightAnchor.constraint(equalTo: idTextField.infoLabel.heightAnchor).isActive = true
                infoButton.translatesAutoresizingMaskIntoConstraints = false
                infoButton.addTarget(self, action: #selector(infoButtonAction), for: .touchUpInside)
            }
        }
    }
    
    @objc func infoButtonAction(sender: UIButton!)
    {
        infoPopTip.bubbleColor = UIColor.gray
        infoPopTip.shouldDismissOnTap = true
        if infoPopTip.isVisible
        {
            infoPopTip.hide()
        }
        if sender.tag == 0
        {
            let txt = K.lang == "ko" ? "????????? ????????? ????????? 5~20 ????????? ??????. (.), (_), (-)??? ??? ????????? ????????? ????????? ?????? ??????????????? ???????????? ???????????? ???????????? (???: __conn, conn.., ???)" :
            "Alphanumeric 5~20 letters. Cannot contain (.), (_), or (-) in the first index and said characters cannot show up consecutively (eg. __conn, conn..)"
            infoPopTip.show(text: txt, direction: .auto, maxWidth: 200, in: self.scrollView, from: sender.frame)
        }
        else if sender.tag == 1
        {
            let txt = K.lang == "ko" ? "??????????????? ?????????, ?????????, ????????? ??????????????? ????????? 8?????? ??????????????? ????????? (???: Conn13!@)" : "Password is alphanumeric 8 letters consisting of at least 1 capital letter and 1 special character (eg. Conn13!@)"
            infoPopTip.show(text: txt, direction: .auto, maxWidth: 200, in: self.scrollView, from: sender.frame)
        }
    }
    
    @IBAction func passwordTFEditingChanged(_ sender: TweeAttributedTextField)
    {
        if let userInput = sender.text
        {
            if userInput.isValidPassword
            {
                if userInput == passwordTextField[1].text
                {
                    passwordTextField[1].hideInfo()
                    passwordTextField[1].showInfo("???")
                }
                sender.infoTextColor = K.mainColor
                sender.showInfo(K.lang == "ko" ? "?????? ????????? ???????????? ?????????" : "Valid password")
                self.pwInfoButton.removeFromSuperview()
            }
            else
            {
                sender.infoTextColor = .red
                let paragraph = NSMutableParagraphStyle()
                paragraph.tabStops = [
                    NSTextTab(textAlignment: .right, location: CGFloat(passwordTextField[0].infoLabel.frame.width-30), options: [:]),
                ]
                let attrString = NSMutableAttributedString(
                    string: K.lang == "ko" ? "??????????????? ????????? ?????? ????????????\t????????? ?????????? " : "Not a valid password\tWhat's a valid password?",
                    attributes: [NSAttributedString.Key.paragraphStyle: paragraph]
                )
                attrString.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.gray], range: NSRange(location: 17, length: 9))
                sender.showInfo(attrString)
                if !self.scrollView.subviews.contains(pwInfoButton)
                {
                    self.scrollView.addSubview(self.pwInfoButton)
                }
                pwInfoButton.leadingAnchor.constraint(equalTo: passwordTextField[0].infoLabel.leadingAnchor, constant: passwordTextField[0].infoLabel.intrinsicContentSize.width+4).isActive = true
                pwInfoButton.topAnchor.constraint(equalTo: passwordTextField[0].infoLabel.topAnchor).isActive = true
                pwInfoButton.heightAnchor.constraint(equalTo: passwordTextField[0].infoLabel.heightAnchor).isActive = true
                pwInfoButton.translatesAutoresizingMaskIntoConstraints = false
                pwInfoButton.addTarget(self, action: #selector(infoButtonAction), for: .touchUpInside)
            }
        }
    }
    
    @IBAction func passwordConfirmTextFieldDidEndEditing(_ sender: TweeAttributedTextField)
    {
        if let userInput = sender.text, let passwordInput = passwordTextField[0].text
        {
            if userInput != passwordInput
            {
                sender.infoTextColor = .red
                sender.showInfo(K.lang == "ko" ? "??????????????? ???????????? ????????????" : "Password does not match")
            }
            else
            {
                sender.showInfo("???")
            }
        }
    }
    
    @IBAction func signUpButtonPressed(_ sender: UIButton)
    {
        sender.isUserInteractionEnabled = false
        sender.backgroundColor = .gray
        FirebaseAuth.Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField[0].text!, completion:
        { authDataResult, error in
            if let error = error
            {
                sender.isUserInteractionEnabled = true
                sender.backgroundColor = K.mainColor
                print(error.localizedDescription)
            }
            else
            {
                let uid = authDataResult?.user.uid
                let userData = ["username": self.idTextField.text!, "email": self.emailTextField.text!, "password": self.passwordTextField[0].text!, "name": self.nameTextField.text!, "verified": false, "uid": uid!, "change": "", "talkingTo":"", "location": GeoPoint(latitude: 0, longitude: 0), "isOnline": false, "statusMsg": "Hello World!", "github": "", "kakao":"", "insta":""]
                
                let userInfoData = ["chatRoom":[], "friends": [], "friendRequestR":[], "friendRequestS":[]]
                
                self.db.collection("users").document(uid!).setData(userData)
                self.db.collection("userInfo").document(uid!).setData(userInfoData)
                let currentUser = FirebaseAuth.Auth.auth().currentUser
                currentUser?.sendEmailVerification(completion:
                { error in
                    if let error = error
                    {
                        print("error with sendemailverification")
                        fatalError(error.localizedDescription)
                    }
                    K.didSignupNewUser = true
                    K.newUserEmail = FirebaseAuth.Auth.auth().currentUser?.email ?? "null@null.null"
                    self.navigationController?.popToRootViewController(animated: true)
                })
            }
        })
    }
    
    @IBAction func emailTFEditingChanged(_ sender: TweeAttributedTextField)
    {
        if let userInput = sender.text
        {
            if !userInput.isValidEmail
            {
                sender.infoLabel.textColor = .red
                sender.showInfo(K.lang == "ko" ? "????????? ????????? ?????? ????????????" : "Not a valid email address")
            }
            else
            {
                sender.hideInfo()
            }
        }
    }
    
    @IBAction func nameTextFieldEditingChanged(_ sender: TweeAttributedTextField)
    {
        if let userInput = sender.text
        {
            if !userInput.isValidName
            {
                sender.infoLabel.textColor = .red
                sender.showInfo(K.lang == "ko" ? "?????? ????????? ?????? ????????????" : "Not a valid name")
            }
            else
            {
                sender.hideInfo()
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        if self.checkIfRequirementsMet()
        {
            self.signUpButton.isUserInteractionEnabled = true
            self.signUpButton.backgroundColor = K.mainColor
        }
        else
        {
            self.signUpButton.isUserInteractionEnabled = false
            self.signUpButton.backgroundColor = .lightGray
        }
    }
}
