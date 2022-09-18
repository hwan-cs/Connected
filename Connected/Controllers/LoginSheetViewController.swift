//
//  LoginSheetViewController.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/09/12.
//


import UIKit
import TweeTextField
import SwiftMessages


class LoginSheetViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate
{
    let defaultHeight: CGFloat = UIScreen.main.bounds.height * 0.457589
    let maximumContainerHeight: CGFloat = UIScreen.main.bounds.height - 100
    // keep updated with new height
    var currentContainerHeight: CGFloat = UIScreen.main.bounds.height * 0.457589
    
    let scrollView = UIScrollView()
    
    @IBOutlet var dragBar: UIView!
    
    var onDismissBlock : ((Bool) -> Void)?
    
    @IBOutlet var usernameTextField: TweeAttributedTextField!
    
    @IBOutlet var passwordTextField: TweeAttributedTextField!
    
    @IBOutlet var eyeImageView: UIImageView!
    
    @IBOutlet var loginBtn: UIButton!

    @IBOutlet var signupBtn: UIButton!
    
    
    // 1
    lazy var containerView: UIView =
    {
        let view = UIView()
        view.backgroundColor = UIColor.white
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
        
        let foobar = MessageView.viewFromNib(layout: .cardView)
        foobar.configureTheme(.success)
        foobar.configureContent(title: "회원가입 성공!", body: "인증 이메일이 보내졌습니다. 링크를 눌러 주세요", iconImage: UIImage(systemName: "checkmark.circle.fill")!)
        foobar.button?.setTitle("확인", for: .normal)
        foobar.buttonTapHandler =
        { _ in
            SwiftMessages.hide()
        }
        var fig = SwiftMessages.defaultConfig
        fig.duration = .forever
        fig.shouldAutorotate = true
        fig.interactiveHide = true
        foobar.layoutMarginAdditions = UIEdgeInsets(top: 50, left: 20, bottom: 0, right: 20)
        SwiftMessages.show(config: fig, view: foobar)
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
        self.dismiss(animated: true)
        {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
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
}
