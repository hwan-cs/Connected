//
//  ProfileSheetViewController.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/10/12.
//

import Foundation
import UIKit
import KFImageViewer
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore
import Cache

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
    
    var email: String?
    
    @IBOutlet var emailLabel: UILabel!
    
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
    
    @IBOutlet var editLabel: UILabel!
    
    var onDismissBlock : ((Bool) -> Void)?
    
    let storage = Storage.storage()
    
    let uuid = Auth.auth().currentUser?.uid
    
    let db = Firestore.firestore()
    
    var didChangeProfilePhoto = false
    
    var didChangeBackgroundPhoto = false
    
    let diskConfig = DiskConfig(name: "FriendCache")
    
    let memoryConfig = MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10)
    
    lazy var cacheStorage: Cache.Storage<String, Data>? =
    {
        return try? Cache.Storage(diskConfig: diskConfig, memoryConfig: memoryConfig, transformer: TransformerFactory.forData())
    }()
    
    var frameSize: CGFloat?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.hideKeyboard()
        self.frameSize = self.view.frame.origin.y
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
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
        self.emailLabel.text = self.email!
        //
        self.toggleEdit(self.editState)
        if !self.isEditable!
        {
            self.editView.removeFromSuperview()
        }
        self.editButton.imageView?.contentMode = .scaleAspectFit
        self.editButton.contentMode = .scaleAspectFit
    }
    
    @objc func keyboardWillShow(notification: NSNotification)
    {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        {
            if self.frameSize == self.view.frame.origin.y
            {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification)
    {
        self.view.frame.origin.y = 0
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
        let imageViewer = FullScreenSlideshowViewController()
        var ims : [ImageSource] = []
        ims.append(ImageSource(image: self.profileImage.image!))
        imageViewer.inputs = ims
        imageViewer.slideshow.activityIndicator = DefaultActivityIndicator(style: UIActivityIndicatorView.Style.medium, color: nil)
        UIApplication.topViewController()?.present(imageViewer, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.view.overrideUserInterfaceStyle = K.darkmode ? .dark : .light
        DispatchQueue.main.async
        {
            if let bg = self.profileBg
            {
                self.profileBackgroundImage.image = bg
                self.profileBackgroundImage.contentMode = .scaleAspectFill
            }
            self.changeNameTextView.text = self.name!
            self.profileImage.image = self.profileImg!
            self.profileImage.contentMode = .scaleAspectFit
            self.changeStatusMsgTextView.text = self.status!
            self.idLabel.text = self.id!
        }
    }
    
    @IBAction func didTapEditButton(_ sender: UIButton)
    {
        self.editState.toggle()
        sender.tintColor = self.editState ? .tintColor : .blue
        let imgToDisplay = self.editState ? UIImage(named: "floppy_disk") : UIImage(named: "Edit")
        sender.imageView?.image = imgToDisplay
        sender.setImage(imgToDisplay, for: .normal)
        let save = K.lang == "ko" ? "저장하기" : "Save"
        let edit = K.lang == "ko" ? "수정하기" : "Edit"
        if self.editLabel.text == save
        {
            Task.init
            {
                let data = try await self.db.collection("users").document(self.uuid!).getDocument().data()
                if let name = data!["name"] as? String
                {
                    if name != self.changeNameTextView.text
                    {
                        try await self.db.collection("users").document(self.uuid!).updateData(["name": self.changeNameTextView.text!])
                        K.myProfileName = self.changeNameTextView.text!
                    }
                }
                if let statusMsg = data!["statusMsg"] as? String
                {
                    if statusMsg != self.changeStatusMsgTextView.text
                    {
                        try await self.db.collection("users").document(self.uuid!).updateData(["statusMsg": self.changeStatusMsgTextView.text!])
                    }
                }
                if let gh = data!["github"] as? String
                {
                    if gh != self.changeGithubTextView.text
                    {
                        try await self.db.collection("users").document(self.uuid!).updateData(["github": self.changeGithubTextView.text!])
                    }
                }
                if let kk = data!["kakao"] as? String
                {
                    if kk != self.changeKakaoTextView.text
                    {
                        try await self.db.collection("users").document(self.uuid!).updateData(["kakao": self.changeKakaoTextView.text!])
                    }
                }
                if let ins = data!["insta"] as? String
                {
                    if ins != self.changeInstaTextView.text
                    {
                        try await self.db.collection("users").document(self.uuid!).updateData(["insta": self.changeInstaTextView.text!])
                    }
                }
            }
            
            let metadata = StorageMetadata()
            let storageRef = self.storage.reference()
            let profileRef = storageRef.child("\(self.uuid!)/ProfileInfo/")
            let profileUUID = UUID().uuidString
            let backgroundUUID = UUID().uuidString
            if self.didChangeProfilePhoto
            {
                let profileImageRef = storageRef.child("\(self.uuid!)/ProfileInfo/profileImage_\(profileUUID).png")
                let profileData = self.profileImage.image?.pngData()
                K.myProfileImg = self.profileImage.image!
                profileRef.listAll(completion:
                { (storageListResult, error) in
                    if let error = error
                    {
                        print(error.localizedDescription)
                    }
                    else
                    {
                        for items in storageListResult!.items
                        {
                            if items.name.contains("profileImage")
                            {
                                print("deleting profile image")
                                items.delete
                                { error in
                                    print("Could not delete \(error?.localizedDescription)")
                                }
                                break
                            }
                        }
                    }
                })
                let uploadProfileTask = profileImageRef.putData(profileData!)
                { metadata, error in
                    if let error = error
                    {
                        print(error.localizedDescription)
                    }
                    else
                    {
                        profileImageRef.getData(maxSize: 30*1024*1024)
                        { data, error in
                            if let error = error
                            {
                                print(error.localizedDescription)
                            }
                            else
                            {
                                self.cacheStorage?.async.setObject(data!, forKey: "\(self.uuid!)_profileImage_\(profileUUID).png", expiry: .date(Calendar.current.date(byAdding: .day, value: 10, to: Date.now)!), completion: {_ in
                                    self.cacheStorage = try? Cache.Storage(diskConfig: self.diskConfig, memoryConfig: self.memoryConfig, transformer: TransformerFactory.forData())
                                })
                            }
                        }
                    }
                }
                self.didChangeProfilePhoto.toggle()
            }
            if self.didChangeBackgroundPhoto
            {
                let backgroundImageRef = storageRef.child("\(self.uuid!)/ProfileInfo/backgroundImage_\(backgroundUUID).png")
                let backgroundData = self.profileBackgroundImage.image?.pngData()
                backgroundImageRef.listAll(completion:
                { (storageListResult, error) in
                    if let error = error
                    {
                        print(error.localizedDescription)
                    }
                    else
                    {
                        for items in storageListResult!.items
                        {
                            if items.name.contains("backgroundImage")
                            {
                                print("deleting background image")
                                items.delete
                                { error in
                                    print("Could not delete \(error?.localizedDescription)")
                                }
                                break
                            }
                        }
                    }
                })
                let uploadBackgroundTask = backgroundImageRef.putData(backgroundData!)
                { metadata, error in
                    if let error = error
                    {
                        print(error.localizedDescription)
                    }
                    else
                    {
                        backgroundImageRef.getData(maxSize: 30*1024*1024)
                        { data, error in
                            if let error = error
                            {
                                print(error.localizedDescription)
                            }
                            else
                            {
                                self.cacheStorage?.async.setObject(data!, forKey: "\(self.uuid!)_backgroundImage_\(backgroundUUID).png", expiry: .date(Calendar.current.date(byAdding: .day, value: 10, to: Date.now)!), completion: {_ in
                                    self.cacheStorage = try? Cache.Storage(diskConfig: self.diskConfig, memoryConfig: self.memoryConfig, transformer: TransformerFactory.forData())
                                })
                                self.onDismissBlock!(true)
                            }
                        }
                    }
                }
                self.didChangeBackgroundPhoto.toggle()
            }
        }
        self.editLabel.text = self.editState ? save : edit
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
            saveButton.setTitle(K.lang == "ko" ? "저장하기" : "Save", for: .normal)
            self.stackView.addSubview(saveButton)
        }
        
        self.containerView.layoutSubviews()
        self.containerView.layoutIfNeeded()
    }
    
    @IBAction func onChangeBackgroundPhotoButtonTap(_ sender: UIButton)
    {
        let imagePicker = UIImagePickerController()
        imagePicker.view.tag = 0
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        UIApplication.topViewController()?.present(imagePicker, animated: true)
    }
    
    
    @IBAction func onChangeProfilePhotoButtonTap(_ sender: UIButton)
    {
        let imagePicker = UIImagePickerController()
        imagePicker.view.tag = 1
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        UIApplication.topViewController()?.present(imagePicker, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        self.didChangeProfilePhoto || self.didChangeBackgroundPhoto ? self.onDismissBlock!(false) : self.onDismissBlock!(true)
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
        if text == "\n"
        {
            textView.resignFirstResponder()
            return false
        }
        return newText.count <= 20
    }
}

extension ProfileSheetViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage
        {
            if picker.view.tag == 0
            {
                self.profileBackgroundImage.image = image
                self.didChangeBackgroundPhoto = true
            }
            else
            {
                self.profileImage.image = image
                self.didChangeProfilePhoto = true
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true, completion: nil)
    }
}


extension UITextView
{
    func constraintWith(identifier: String) -> NSLayoutConstraint?
    {
        return self.constraints.first(where: {$0.identifier == identifier})
    }
}

