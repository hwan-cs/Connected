//
//  LoginSheetViewController.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/09/12.
//


import UIKit
import TweeTextField
import SwiftMessages
import AMPopTip
import FirebaseAuth
import Firebase
import TransitionButton
import FirebaseFirestore

class LoginSheetViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate
{
    let defaultHeight: CGFloat = UIScreen.main.bounds.height * 0.457589
    let maximumContainerHeight: CGFloat = UIScreen.main.bounds.height - 100
    // keep updated with new height
    var currentContainerHeight: CGFloat = UIScreen.main.bounds.height * 0.457589
    
    let scrollView = UIScrollView()
    
    @IBOutlet var dragBar: UIView!
    
    @IBOutlet var usernameTextField: TweeAttributedTextField!
    
    @IBOutlet var passwordTextField: TweeAttributedTextField!
    
    @IBOutlet var eyeImageView: UIImageView!
    
    @IBOutlet var loginBtn: TransitionButton!

    @IBOutlet var signupBtn: UIButton!
    
    let resendEmail = UIButton()
    
    let questionPopTip = PopTip()
    
    var db = Firestore.firestore()
    
    var timer = Timer()
    
    // 1
    lazy var containerView: UIView =
    {
        let view = UIView()
        view.backgroundColor = UIColor(named: "BackgroundColor2")
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    // 3. Dynamic container constraint
    var containerViewHeightConstraint: NSLayoutConstraint?
    var containerViewBottomConstraint: NSLayoutConstraint?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.hideKeyboard()
        eyeImageView.tag = 0
        setupView()
        setupConstraints()
        setupPanGesture()
        self.passwordTextField.infoTextColor = .red
        if K.isTimerRunning
        {
            self.runResendEmailTimer()
        }
        
        self.usernameTextField.text = ""
        self.passwordTextField.text = ""
    }
    
    func setupView()
    {
        view.backgroundColor = .clear
    }
    
    func animatePresentContainer()
    {
        // Update bottom constraint in animation block
        UIView.animate(withDuration: 0.3)
        {
            self.containerViewBottomConstraint?.constant = 0
            // Call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        self.view.overrideUserInterfaceStyle = K.darkmode ? .dark : .light
        animatePresentContainer()
    }
    
    func animateDismissView()
    {
        // hide main container view by updating bottom constraint in animation block
        UIView.animate(withDuration: 0.3)
        {
            self.containerViewBottomConstraint?.constant = self.defaultHeight
            // call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
        
        // hide blur view
        completion:
        { _ in
            // once done, dismiss without animation
            self.dismiss(animated: false)
        }
    }
    
    func setupPanGesture()
    {
        // add pan gesture recognizer to the view controller's view (the whole screen)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(gesture:)))
        // change to false to immediately listen on gesture movement
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        view.addGestureRecognizer(panGesture)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapEyeImageView(tapGestureRecognizer:)))
        eyeImageView.isUserInteractionEnabled = true
        eyeImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer)
    {
        let translation = gesture.translation(in: view)
        // Drag to top will be minus value and vice versa

        // Get drag direction
        let isDraggingDown = translation.y > 0

        // New height is based on value of dragging plus current container height
        let newHeight = currentContainerHeight - translation.y

        // Handle based on gesture state
        switch gesture.state
        {
        case .changed:
            // This state will occur when user is dragging
            if newHeight < maximumContainerHeight && newHeight > defaultHeight
            {
                // Keep updating the height constraint
                containerViewHeightConstraint?.constant = newHeight
                // refresh layout
                view.layoutIfNeeded()
            }
        case .ended:
            // This happens when user stop drag,
            // so we will get the last height of container
            // Condition 1: If new height is below min, dismiss controller
            if newHeight < maximumContainerHeight && isDraggingDown
            {
                // Condition 3: If new height is below max and going down, set to default height
                animateContainerHeight(defaultHeight)
            }
            else if newHeight > defaultHeight && !isDraggingDown
            {
                // Condition 4: If new height is below max and going up, set to max height at top
                animateContainerHeight(maximumContainerHeight)
            }
        default:
            break
        }
    }
    
    @objc func didTapEyeImageView(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        if tappedImage.tag == 0
        {
            passwordTextField.isSecureTextEntry = false
            tappedImage.image = UIImage(systemName: "eye.slash")
            tappedImage.tag = 1
        }
        else
        {
            passwordTextField.isSecureTextEntry = true
            tappedImage.image = UIImage(systemName: "eye")
            tappedImage.tag = 0
        }
    }
    
    @IBAction func didTapSignUp(_ sender: UIButton)
    {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
        self.dismiss(animated: true)
        {
            UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        animateContainerHeight(maximumContainerHeight)
    }
    
    func animateContainerHeight(_ height: CGFloat)
    {
        UIView.animate(withDuration: 0.4)
        {
            // Update container height
            self.containerViewHeightConstraint?.constant = height
            // Call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
        // Save current height
        currentContainerHeight = height
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        self.view.endEditing(true)
        return false
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.usernameTextField.tweePlaceholder = K.lang == "ko" ? "?????????" : "Email"
        self.passwordTextField.tweePlaceholder = K.lang == "ko" ? "????????????" : "Password"
        self.checkUserLogin()
        if K.didSignupNewUser
        {
            let foobar = MessageView.viewFromNib(layout: .cardView)
            foobar.configureTheme(.success)
            let iconText = ["????", "????", "????", "????"].randomElement()!
            let title = K.lang == "ko" ? "???????????? ??????!" : "Signed up successfully!"
            let body = K.lang == "ko" ? "\(K.newUserEmail)??? ?????? ???????????? ??????????????????. ???????????? ?????? ????????? ?????? ?????????" : "Verification email sent to \(K.newUserEmail). Please check your email inbox"
            foobar.configureContent(title: title, body: body, iconText: iconText)
            foobar.button?.setTitle("??????", for: .normal)
            foobar.buttonTapHandler =
            { _ in
                SwiftMessages.hide()
            }
            var fig = SwiftMessages.defaultConfig
            fig.duration = .automatic
            fig.shouldAutorotate = true
            fig.interactiveHide = true
            foobar.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20)
            SwiftMessages.show(config: fig, view: foobar)
            K.newUserEmail = "null@null.null"
            K.didSignupNewUser.toggle()
        }
    }
    
    func checkUserLogin()
    {
        // to check whether the user has already logged in or not
        Auth.auth().addStateDidChangeListener
        { (auth, user) in
            if user == nil
            {
                print("nil")
                self.passwordTextField.hideInfo(animated: false)
                let infoText = K.lang == "ko" ? "???????????? ???????????????! ?????? ????????? ????????????" : "Logged out! Please log back in"
                self.passwordTextField.showInfo(infoText, animated: true)
                do
                {
                    try Auth.auth().signOut()
                }
                catch
                {
                    print(error.localizedDescription)
                }
            }
            else
            {
                print("is not nil")
                Task.init
                {
                    try await Auth.auth().updateCurrentUser(user!)
                }
            }
        }
    }
    
    @IBAction func didTapLogin(_ sender: TransitionButton)
    {
        sender.isUserInteractionEnabled = false
        sender.backgroundColor = .gray
        sender.startAnimation()
        if !(usernameTextField.text?.isValidEmail ?? true) && !(passwordTextField.text?.isValidPassword ?? true)
        {
            sender.isUserInteractionEnabled = true
            sender.backgroundColor = UIColor(red: 0.02, green: 0.78, blue: 0.51, alpha: 1.00)
            sender.stopAnimation(animationStyle: .shake)
            sender.cornerRadius = 14
            sender.setTitle(K.lang == "ko" ? "?????????" : "Login", for: .normal)
            return
        }
        else
        {
            var flag = false
            Task.init
            {
                flag = await self.userDoesExist(self.usernameTextField.text!)
                if !flag
                {
                    for sv in self.view.subviews
                    {
                        if sv.tag == 37 || sv.tag == 38
                        {
                            sv.removeFromSuperview()
                        }
                    }
                    passwordTextField.hideInfo(animated: false)
                    let infoText = K.lang == "ko" ? "???????????? ?????? ????????? ?????????! ??????????????? ?????? ?????? ????????????" : "User doesn't exist! Please sign up first"
                    passwordTextField.showInfo(infoText, animated: true)
                    sender.isUserInteractionEnabled = true
                    sender.backgroundColor = UIColor(red: 0.02, green: 0.78, blue: 0.51, alpha: 1.00)
                    sender.stopAnimation(animationStyle: .shake)
                    sender.cornerRadius = 14
                    sender.setTitle(K.lang == "ko" ? "?????????" : "Login", for: .normal)
                    return
                }
                do
                {
                    try await Auth.auth().signIn(withEmail: self.usernameTextField.text!, password: self.passwordTextField.text!)
                    print("success")
                }
                catch
                {
                    sender.isUserInteractionEnabled = true
                    sender.backgroundColor = UIColor(red: 0.02, green: 0.78, blue: 0.51, alpha: 1.00)
                    sender.stopAnimation(animationStyle: .shake)
                    sender.cornerRadius = 14
                    sender.setTitle(K.lang == "ko" ? "?????????" : "Login", for: .normal)
                    let msg = K.lang == "ko" ? "??????????????? ???????????????!" : "Wrong password!"
                    let alert = UIAlertController(title: "", message: msg, preferredStyle: .alert)
                    self.present(alert, animated: true, completion: nil)

                    let when = DispatchTime.now() + 1.5
                    DispatchQueue.main.asyncAfter(deadline: when)
                    {
                      alert.dismiss(animated: true, completion: nil)
                    }
                    return
                }
                guard let currentUser = Auth.auth().currentUser
                else
                {
                    fatalError()
                }
                currentUser.reload
                { error in
                    if let error = error
                    {
                        fatalError(error.localizedDescription)
                    }
                    switch currentUser.isEmailVerified
                    {
                    case true:
                        Task.init
                        {
                            let snapshotDocuments = try await self.db.collection("users").whereField("username", isNotEqualTo: false).getDocuments().documents
                            for doc in snapshotDocuments
                            {
                                let data = doc.data()
                                if let email = doc["email"] as? String
                                {
                                    if email == currentUser.email!
                                    {
                                        if let verified = data["verified"] as? Bool
                                        {
                                            if !verified
                                            {
                                                try await doc.reference.updateData(["verified":true])
                                            }
                                        }
                                        self.dismiss(animated: true)
                                        {
                                            K.myProfileName = data["name"] as? String
                                            K.myProfileUsername = data["username"] as? String
                                            K.myProfileEmail = data["email"] as? String
                                            K.myProfilePassword = data["password"] as? String
                                            self.timer.invalidate()
                                            sender.stopAnimation(animationStyle: .expand)
                                            {
                                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainPageNavigationController") as! UINavigationController
                                                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                                                windowScene?.windows.first?.rootViewController = vc
                                                windowScene?.windows.first?.makeKeyAndVisible()
                                            }
                                            sender.cornerRadius = 14
                                            sender.setTitle(K.lang == "ko" ? "?????????" : "Login", for: .normal)
                                        }
                                    }
                                }
                            }
                        }
                    case false:
                        let foobar = MessageView.viewFromNib(layout: .cardView)
                        foobar.configureTheme(.error)
                        let iconText = ["????","????","????","????","????","????","????","????"].randomElement()!
                        foobar.titleLabel?.numberOfLines = 0
                        foobar.bodyLabel?.numberOfLines = 0
                        let title = K.lang == "ko" ? "????????? ????????? ???????????? ???????????????!" : "Email verification is not complete"
                        let body = K.lang == "ko" ? "\(currentUser.email!)??? ????????? ?????? ????????? ???????????????" : "Please open the verification link sent to \(currentUser.email!)"
                        foobar.configureContent(title: title, body: body, iconText: iconText)
                        foobar.button?.setTitle(K.lang == "ko" ? "??????" : "Ok", for: .normal)
                        foobar.buttonTapHandler =
                        { _ in
                            SwiftMessages.hide()
                        }
                        var fig = SwiftMessages.defaultConfig
                        fig.duration = .automatic
                        fig.shouldAutorotate = true
                        fig.interactiveHide = true
                        foobar.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20)
                        SwiftMessages.show(config: fig, view: foobar)
                        
                        let questionButton = UIButton()
                        questionButton.tag = 37
                        questionButton.tintColor = .systemGray
                        questionButton.setImage(UIImage(systemName: "questionmark.circle.fill"), for: .normal)
                        self.passwordTextField.hideInfo(animated: false)
                        self.passwordTextField.showInfo(K.lang == "ko" ? "???????????? ?????? ????????????? " : "Didn't receive an email")
                        if !self.view.subviews.contains(questionButton)
                        {
                            self.view.addSubview(questionButton)
                        }
                        questionButton.leadingAnchor.constraint(equalTo: self.passwordTextField.infoLabel.leadingAnchor, constant: self.passwordTextField.infoLabel.intrinsicContentSize.width+4).isActive = true
                        questionButton.topAnchor.constraint(equalTo: self.passwordTextField.infoLabel.topAnchor).isActive = true
                        questionButton.heightAnchor.constraint(equalTo: self.passwordTextField.infoLabel.heightAnchor).isActive = true
                        questionButton.translatesAutoresizingMaskIntoConstraints = false
                        questionButton.addTarget(self, action: #selector(self.questionButtonAction), for: .touchUpInside)
                        if K.isTimerRunning
                        {
                            return
                        }
                        self.makeResendEmailButton()
                        sender.isUserInteractionEnabled = true
                        sender.backgroundColor = UIColor(red: 0.02, green: 0.78, blue: 0.51, alpha: 1.00)
                        sender.stopAnimation(animationStyle: .shake)
                        sender.cornerRadius = 14
                        sender.setTitle(K.lang == "ko" ? "?????????" : "Login", for: .normal)
                    }
                }
            }
        }
    }
    
    @objc func questionButtonAction(sender: UIButton!)
    {
        questionPopTip.bubbleColor = UIColor.gray
        questionPopTip.shouldDismissOnTap = true
        if questionPopTip.isVisible
        {
            questionPopTip.hide()
        }
        questionPopTip.show(text: K.lang == "ko" ? "???????????? ?????? ????????????!" : "Check your Spam inbox!", direction: .auto, maxWidth: 150, in: self.view, from: sender.frame)
    }
    
    @objc func sendEmail()
    {
        self.resendEmail.isUserInteractionEnabled = false
        guard let currentUser = Auth.auth().currentUser
        else
        {
            fatalError("sign in with Auth.auth()")
        }
        currentUser.sendEmailVerification
        { error in
            if let error = error
            {
                fatalError(error.localizedDescription)
            }
            K.isTimerRunning.toggle()
            self.runResendEmailTimer()
            return print("User verification mail sent")
        }
    }
    
    func userDoesExist(_ email: String) async -> Bool
    {
        let collectionRef = db.collection("users")
        do
        {
            let snapshotDocuments = try await collectionRef.whereField("email", isEqualTo: email).getDocuments().documents
            if snapshotDocuments.isEmpty
            {
                print("user doesnt exist")
                return false
            }
        }
        catch
        {
            print(error.localizedDescription)
        }
        print("user exist")
        return true
    }
    
    func runResendEmailTimer()
    {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer()
    {
        if !self.view.subviews.contains(resendEmail)
        {
            self.view.addSubview(resendEmail)
            resendEmail.trailingAnchor.constraint(equalTo: self.passwordTextField.infoLabel.trailingAnchor).isActive = true
            resendEmail.topAnchor.constraint(equalTo: self.passwordTextField.infoLabel.topAnchor).isActive = true
            resendEmail.heightAnchor.constraint(equalTo: self.passwordTextField.infoLabel.heightAnchor).isActive = true
            resendEmail.translatesAutoresizingMaskIntoConstraints = false
            resendEmail.isUserInteractionEnabled = false
        }
        let attr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .backgroundColor: UIColor.clear,
            .foregroundColor: UIColor.gray,
        ]
        
        let attrString = NSMutableAttributedString(
            string: K.lang == "ko" ? "\(K.seconds)??? ??? ????????? ??? ??? ????????????" : "Can send again after \(K.seconds) second(s)",
            attributes: attr
        )
        resendEmail.setAttributedTitle(attrString, for: .normal)
        if K.seconds == 0
        {
            timer.invalidate()
            K.seconds = 60
            resendEmail.removeFromSuperview()
            if self.view.subviews.contains(where: { view in
                return view.tag == 37
            })
            {
                makeResendEmailButton()
            }
        }
        K.seconds -= 1
    }
    
    func makeResendEmailButton()
    {
        resendEmail.isUserInteractionEnabled = true
        resendEmail.tag = 38
        let attr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .backgroundColor: UIColor.clear,
            .foregroundColor: UIColor.blue,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
        let attrString = NSMutableAttributedString(
            string: K.lang == "ko" ? "????????? ?????????" : "Resend email",
            attributes: attr
        )
        resendEmail.addTarget(self, action: #selector(self.sendEmail), for: .touchUpInside)
        resendEmail.setAttributedTitle(attrString, for: .normal)
        if !self.view.subviews.contains(resendEmail)
        {
            self.view.addSubview(resendEmail)
        }
        resendEmail.trailingAnchor.constraint(equalTo: self.passwordTextField.infoLabel.trailingAnchor).isActive = true
        resendEmail.topAnchor.constraint(equalTo: self.passwordTextField.infoLabel.topAnchor).isActive = true
        resendEmail.heightAnchor.constraint(equalTo: self.passwordTextField.infoLabel.heightAnchor).isActive = true
        resendEmail.translatesAutoresizingMaskIntoConstraints = false
    }
}
