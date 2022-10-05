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
                idTextField.showInfo("중복된 아이디 입니다!", animated: true)
            }
            else
            {
                activityView.stopAnimating()
                idTextField.infoTextColor = K.mainColor
                idTextField.layer.borderColor = K.mainColor.cgColor
                idTextField.showInfo("사용 가능한 아이디 입니다!", animated: true)
//                remove poptip
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
                checkDuplicateButton.titleLabel?.textColor = K.mainColor
                checkDuplicateButton.tintColor = K.mainColor
                checkDuplicateButton.isUserInteractionEnabled = true
                idTextField.infoTextColor = K.mainColor
                idTextField.showInfo("형식에 맞는 아이디 입니다")
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
                    string: "형식에 맞지 않습니다\t형식이 뭔가요? ",
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
            infoPopTip.show(text: "영어와 숫자를 포함한 5~20 길이의 글자. (.), (_), (-)가 맨 처음에 있으면 안되며 해당 특수문자는 연속으로 나타나지 않습니다 (예: __conn, conn.., 등)", direction: .auto, maxWidth: 200, in: self.scrollView, from: sender.frame)
        }
        else if sender.tag == 1
        {
            infoPopTip.show(text: "비밀번호는 대문자, 소문자, 숫자와 특수문자를 포함한 8글자 이상이어야 합니다 (예: Conn13!)", direction: .auto, maxWidth: 200, in: self.scrollView, from: sender.frame)
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
                    passwordTextField[1].showInfo("✅")
                }
                sender.infoTextColor = K.mainColor
                sender.showInfo("사용 가능한 비밀번호 입니다")
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
                    string: "비밀번호가 형식에 맞지 않습니다\t형식이 뭔가요? ",
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
                sender.showInfo("비밀번호가 일치하지 않습니다")
            }
            else
            {
                sender.showInfo("✅")
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
                let userData = ["username": self.idTextField.text!, "email": self.emailTextField.text!, "password": self.passwordTextField[0].text!, "name": self.nameTextField.text!, "verified": false, "uid": uid!, "change": "", "talkingTo":"", "location": GeoPoint(latitude: 0, longitude: 0), "isSharingLocation": false, "isOnline": false]
                
                let userInfoData = ["chatRoom":[], "friends": []]
                
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
                sender.showInfo("이메일 형식에 맞지 않습니다")
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
                sender.showInfo("이름 형식에 맞지 않습니다")
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
