//
//  ProfileSheetViewController.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/10/12.
//

import Foundation
import UIKit
import KFImageViewer

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
    
    @IBOutlet var stackView: UIStackView!
    
    @IBOutlet var changeProfilePhotoButton: UIButton!
    
    @IBOutlet var editView: UIView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.hideKeyboard()
        self.profileImage.layer.cornerRadius = 16.0
        
        self.profileBackgroundImage.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.didTapProfileBackgroundPhoto))
        self.profileBackgroundImage.addGestureRecognizer(tap)
        
        self.profileImage.isUserInteractionEnabled = true
        let tapPf = UITapGestureRecognizer(target: self, action: #selector(self.didTapProfilePhoto))
        self.profileImage.addGestureRecognizer(tapPf)
        
        self.profileBackgroundImage.layer.masksToBounds = true
        self.profileBackgroundImage.layer.cornerRadius = 16.0
        self.profileBackgroundImage.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.profileBackgroundImage.layer.borderColor = UIColor.lightGray.cgColor
        self.profileBackgroundImage.layer.borderWidth = 0.5
        self.changeNameTextView.delegate = self
        self.changeStatusMsgTextView.delegate = self
        self.changeGithubTextView.delegate = self
        self.changeKakaoTextView.delegate = self
        self.changeInstaTextView.delegate = self
        
        self.changeNameTextView.textContainer.maximumNumberOfLines = 1
        self.changeNameTextView.textContainerInset = .zero
        self.changeNameTextView.isScrollEnabled = false
        self.changeNameTextView.sizeToFit()
        self.changeStatusMsgTextView.textContainer.maximumNumberOfLines = 1
        self.changeStatusMsgTextView.textContainerInset = .zero
        self.changeStatusMsgTextView.isScrollEnabled = false
        self.changeStatusMsgTextView.sizeToFit()
        self.changeGithubTextView.textContainer.maximumNumberOfLines = 1
        self.changeGithubTextView.textContainerInset = .zero
        self.changeGithubTextView.textContainer.lineFragmentPadding = 2
        self.changeGithubTextView.isScrollEnabled = false
        self.changeGithubTextView.sizeToFit()
        self.changeKakaoTextView.textContainer.maximumNumberOfLines = 1
        self.changeKakaoTextView.textContainerInset = .zero
        self.changeKakaoTextView.textContainer.lineFragmentPadding = 2
        self.changeKakaoTextView.isScrollEnabled = false
        self.changeKakaoTextView.sizeToFit()
        self.changeInstaTextView.textContainer.maximumNumberOfLines = 1
        self.changeInstaTextView.textContainerInset = .zero
        self.changeInstaTextView.textContainer.lineFragmentPadding = 2
        self.changeInstaTextView.isScrollEnabled = false
        self.changeInstaTextView.sizeToFit()
        
        self.changeNameTextView.text = self.name!
        self.changeStatusMsgTextView.text = self.status!
        self.changeGithubTextView.text = self.github!
        self.changeKakaoTextView.text = self.kakao!
        self.changeInstaTextView.text = self.insta!
        
        self.toggleEdit(self.editState)
        if !self.isEditable!
        {
            self.editView.removeFromSuperview()
        }
    
    }
    
    @objc func didTapProfileBackgroundPhoto()
    {
        let imageViewer = FullScreenSlideshowViewController()
        var ims : [ImageSource] = []
        ims.append(ImageSource(image: self.profileBackgroundImage.image!))
        imageViewer.inputs = ims
        imageViewer.slideshow.activityIndicator = DefaultActivityIndicator(style: UIActivityIndicatorView.Style.medium, color: nil)
        UIApplication.topViewController()?.present(imageViewer, animated: true)
    }
    
    @objc func didTapProfilePhoto()
    {
        print("tapped profile pic")
        let imageViewer = FullScreenSlideshowViewController()
        var ims : [ImageSource] = []
        ims.append(ImageSource(image: self.profileImage.image!))
        imageViewer.inputs = ims
        imageViewer.slideshow.activityIndicator = DefaultActivityIndicator(style: UIActivityIndicatorView.Style.medium, color: nil)
        UIApplication.topViewController()?.present(imageViewer, animated: true)
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
        self.editState.toggle()
        print(self.editState)
        sender.tintColor = self.editState ? .tintColor : .blue
        self.toggleEdit(self.editState)
    }
    
    func toggleEdit(_ flag: Bool)
    {
        self.changeBackgroundPhotoButton.isHidden = !flag
        self.profileBackgroundImage.isUserInteractionEnabled = !flag
        self.profileImage.isUserInteractionEnabled = !flag
        self.changeBackgroundPhotoButton.isUserInteractionEnabled = flag
        self.changeProfilePhotoButton.isHidden = !flag
        self.changeProfilePhotoButton.isUserInteractionEnabled = flag
        
        self.changeNameTextView.isEditable = flag
        self.changeStatusMsgTextView.isEditable = flag
        self.changeGithubTextView.isEditable = flag
        self.changeKakaoTextView.isEditable = flag
        self.changeInstaTextView.isEditable = flag
        
        self.changeNameTextView.backgroundColor = flag ? .lightGray.withAlphaComponent(0.3) : .clear
        self.changeStatusMsgTextView.backgroundColor = flag ? .lightGray.withAlphaComponent(0.4) : .clear
        self.changeGithubTextView.backgroundColor = flag ? .lightGray.withAlphaComponent(0.5) : .clear
        self.changeKakaoTextView.backgroundColor = flag ? .lightGray.withAlphaComponent(0.6) : .clear
        self.changeInstaTextView.backgroundColor = flag ? .lightGray.withAlphaComponent(0.7) : .clear
        
        if flag
        {
            let saveButton = UIButton()
            saveButton.setTitle("저장하기", for: .normal)
            self.stackView.addSubview(saveButton)
        }
        
        self.containerView.layoutSubviews()
        self.containerView.layoutIfNeeded()
    }
}

extension ProfileSheetViewController: UITextViewDelegate
{
    func textViewDidChange(_ textView: UITextView)
    {
        if let myConstraint = textView.constraintWith(identifier: "widthConstraint")
        {
            let fixedHeight = textView.frame.size.height
            let width = textView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: fixedHeight)).width
            myConstraint.constant = textView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: fixedHeight)).width
        }
        textView.updateConstraints()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count <= 30
    }
}


extension UITextView
{
    func constraintWith(identifier: String) -> NSLayoutConstraint?
    {
        return self.constraints.first(where: {$0.identifier == identifier})
    }
}
