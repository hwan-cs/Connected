//
//  SignupVC_Extensions.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/09/18.
//

import Foundation

extension SignupViewController
{
    func checkIfRequirementsMet() -> Bool
    {
        if idTextField.text?.isValidUsername ?? false && isDuplicateID == false && passwordTextField[1].text?.isValidPassword ?? false && passwordTextField[0].text == passwordTextField[1].text && emailTextField.text?.isValidEmail ?? false && nameTextField.text?.isValidName ?? false
        {
            return true
        }
        return false
    }
}
