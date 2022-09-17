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
import AMPopTip

class SignupViewController: UIViewController, UIScrollViewDelegate
{
    @IBOutlet var idTextField: TweeAttributedTextField!
    
    @IBOutlet var emailTextField: TweeAttributedTextField!
    
    @IBOutlet var verifyTextField: TweeAttributedTextField!
    
    @IBOutlet var scrollView: UIScrollView!

    @IBOutlet var passwordTextField: [TweeAttributedTextField]!
    
    @IBOutlet var eyeImageVIew: [UIImageView]!
    
    @IBOutlet var checkDuplicateButton: UIButton!
    
    var db = Firestore.firestore()
    
    let activityView = UIActivityIndicatorView(style: .medium)
    
    let infoButton = UIButton()
    
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
                idTextField.infoTextColor = UIColor(red: 0.02, green: 0.78, blue: 0.51, alpha: 1.00)
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
                    string: "형식에 맞지 않습니다!\t형식이 뭔가요? ",
                    attributes: [NSAttributedString.Key.paragraphStyle: paragraph]
                )
                attrString.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0)], range: NSRange(location: 0, length: attrString.length-1))
                attrString.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.gray], range: NSRange(location: 13, length: 9))
                idTextField.showInfo(attrString)
                infoButton.tintColor = .systemGray
                infoButton.setImage(UIImage(systemName: "info.circle.fill"), for: .normal)
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
        let infoPopTip = PopTip()
        infoPopTip.bubbleColor = UIColor.gray
        infoPopTip.shouldDismissOnTap = true
        infoPopTip.show(text: "영어와 숫자를 포함한 5~20 길이의 글자. (.), (_), (-)가 맨 처음에 있으면 안되며 해당 특수문자는 연속으로 나타나지 않습니다 (예: __conn, conn.., 등", direction: .auto, maxWidth: 200, in: self.scrollView, from: sender.frame)
    }
    
    @IBAction func passwordTextFieldEditingChanged(_ sender: TweeAttributedTextField)
    {
        if let userInput = sender.text
        {
            if userInput.isValidPassword
            {
                passwordTextField[0].infoTextColor = UIColor(red: 0.02, green: 0.78, blue: 0.51, alpha: 1.00)
                passwordTextField[0].showInfo("사용 가능한 비밀번호 입니다")
            }
            else
            {
                passwordTextField[0].infoTextColor = .red
                passwordTextField[0].showInfo("비밀번호는 대문자, 소문자, 숫자와 특수문자를 포함한 8글자 이상이어야 합니다")
            }
        }
    }
    
    @IBAction func passwordConfirmTextFieldDidEndEditing(_ sender: TweeAttributedTextField)
    {
        if let userInput = sender.text, let passwordInput = passwordTextField[0].text
        {
            if userInput != passwordInput
            {
                passwordTextField[1].infoTextColor = .red
                passwordTextField[1].showInfo("비밀번호가 일치하지 않습니다")
            }
            else
            {
                passwordTextField[1].infoTextColor = UIColor(red: 0.02, green: 0.78, blue: 0.51, alpha: 1.00)
                passwordTextField[1].infoLabel.largeContentImage = UIImage(systemName: "checkmark")
            }
        }
    }
}
