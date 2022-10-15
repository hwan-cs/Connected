//
//  ProfileSheetViewController.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/10/12.
//

import Foundation
import UIKit

class ProfileSheetViewController: UIViewController
{
    @IBOutlet var containerView: UIView!
    
    @IBOutlet var profileBackgroundImage: UIImageView!
    
    var profileBg: UIImage?
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet var profileImage: UIImageView!
    
    var profileImg: UIImage?
    
    var name: String?
    
    var status: String?
    
    @IBOutlet var idLabel: UILabel!
    
    var id: String?
    
    var isEditable: Bool?
    
    @IBOutlet var editButton: UIButton!
    
    var editState = false
    
    @IBOutlet var changeBackgroundPhotoButton: UIButton!
    
    @IBOutlet var changeNameTextView: UITextView!
    
    @IBOutlet var changeStatusMsgTextView: UITextView!
    
    @IBOutlet var changeGithubTextView: UITextView!
    
    @IBOutlet var changeKakaoTextView: UITextView!
    
    @IBOutlet var changeInstaTextView: UITextView!
    
    var github: String?
    
    var kakao: String?
    
    var insta: String?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.hideKeyboard()
        self.profileImage.layer.cornerRadius = 16.0
        self.profileBackgroundImage.layer.masksToBounds = true
        self.profileBackgroundImage.layer.cornerRadius = 16.0
        self.profileBackgroundImage.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.profileBackgroundImage.layer.borderColor = UIColor.lightGray.cgColor
        self.profileBackgroundImage.layer.borderWidth = 0.5
        
        self.changeNameTextView.textContainer.maximumNumberOfLines = 1
        self.changeNameTextView.textContainerInset = .zero
        self.changeNameTextView.isScrollEnabled = false
        self.changeStatusMsgTextView.textContainer.maximumNumberOfLines = 1
        self.changeStatusMsgTextView.textContainerInset = .zero
        self.changeStatusMsgTextView.isScrollEnabled = false
        self.changeGithubTextView.textContainer.maximumNumberOfLines = 1
        self.changeGithubTextView.textContainerInset = .zero
        self.changeGithubTextView.textContainer.lineFragmentPadding = 0
        self.changeGithubTextView.isScrollEnabled = false
        self.changeKakaoTextView.textContainer.maximumNumberOfLines = 1
        self.changeKakaoTextView.textContainerInset = .zero
        self.changeKakaoTextView.textContainer.lineFragmentPadding = 0
        self.changeKakaoTextView.isScrollEnabled = false
        self.changeInstaTextView.textContainer.maximumNumberOfLines = 1
        self.changeInstaTextView.textContainerInset = .zero
        self.changeInstaTextView.textContainer.lineFragmentPadding = 0
        self.changeInstaTextView.isScrollEnabled = false
        
        self.changeNameTextView.text = self.name!
        self.changeStatusMsgTextView.text = self.status!
        self.changeGithubTextView.text = self.github!
        self.changeKakaoTextView.text = self.kakao!
        self.changeInstaTextView.text = self.insta!
        
        self.toggleEdit(self.editState)
        
        self.contentView.bringSubviewToFront(self.editButton)
        
        if !self.isEditable!
        {
            self.editButton.removeFromSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        DispatchQueue.main.async
        {
            if let bg = self.profileBg
            {
                self.profileBackgroundImage.image = bg
            }
            self.changeNameTextView.text = self.name!
            self.profileImage.image = self.profileImg!
            self.changeStatusMsgTextView.text = self.status!
            self.idLabel.text = self.id!
        }
    }
    
    @IBAction func didTapEditButton(_ sender: UIButton)
    {
        print("tapped")
        self.editState.toggle()
        print(self.editState)
        sender.tintColor = self.editState ? .tintColor : .blue
        self.toggleEdit(self.editState)
    }
    
    func toggleEdit(_ flag: Bool)
    {
        self.changeBackgroundPhotoButton.isHidden = !flag
        self.changeBackgroundPhotoButton.isUserInteractionEnabled = flag
        
        self.changeNameTextView.isEditable = flag
        self.changeStatusMsgTextView.isEditable = flag
        self.changeGithubTextView.isEditable = flag
        self.changeKakaoTextView.isEditable = flag
        self.changeInstaTextView.isEditable = flag
        
        self.changeNameTextView.backgroundColor = flag ? .lightGray : .clear
        self.changeStatusMsgTextView.backgroundColor = flag ? .lightGray : .clear
        self.changeGithubTextView.backgroundColor = flag ? .lightGray : .clear
        self.changeKakaoTextView.backgroundColor = flag ? .lightGray : .clear
        self.changeInstaTextView.backgroundColor = flag ? .lightGray : .clear
        
        self.containerView.layoutSubviews()
        self.containerView.layoutIfNeeded()
    }
}
