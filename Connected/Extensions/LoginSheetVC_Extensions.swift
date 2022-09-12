//
//  LoginSheetVC_Extensions.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/09/12.
//

import Foundation
import UIKit
import TweeTextField

extension LoginSheetViewController
{
    func setupConstraints()
    {
        // 4. Add subviews
        usernameTextField.setUI()
        passwordTextField.setUI()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(containerView)
        scrollView.addSubview(usernameTextField)
        scrollView.addSubview(passwordTextField)
        scrollView.addSubview(loginBtn)
        containerView.addSubview(scrollView)
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        usernameTextField.translatesAutoresizingMaskIntoConstraints = false
        loginBtn.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // 5. Set static constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: containerView.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // set container static constraint (trailing & leading)
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            usernameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            usernameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            usernameTextField.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 40),
            usernameTextField.heightAnchor.constraint(equalToConstant: 52.0),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            passwordTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 30),
            passwordTextField.heightAnchor.constraint(equalToConstant: 52.0),
            loginBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            loginBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            loginBtn.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 30),
            loginBtn.heightAnchor.constraint(equalToConstant: 52.0),
        ])
        // 6. Set container to default height
        containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: defaultHeight)
        // 7. Set bottom constant to 0
        containerViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        // Activate constraints
        containerViewHeightConstraint?.isActive = true
        containerViewBottomConstraint?.isActive = true
        
    }
}
