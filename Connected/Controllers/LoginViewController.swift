//
//  ViewController.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/09/09.
//

import UIKit
import TweeTextField
import SwiftUI
import SwiftMessages

class LoginViewController: UIViewController
{
    var presentTransition: UIViewControllerAnimatedTransitioning?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.backButtonTitle = "뒤로가기"
        self.navigationController?.navigationBar.tintColor = K.mainColor
        presentTransition = CustomTransition()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginSheetViewController") as! LoginSheetViewController
        vc.modalPresentationStyle = .overCurrentContext
        vc.transitioningDelegate = self
        self.present(vc, animated: true, completion: { [weak self] in
            self?.presentTransition = nil
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        self.view.endEditing(true)
        return false
    }
}

extension LoginViewController:UIViewControllerTransitioningDelegate
{
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return presentTransition
    }
}

extension FriendsViewController:UIViewControllerTransitioningDelegate
{
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return presentTransition
    }
}
