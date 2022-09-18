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
            print("OK")
            return true
        }
        print(idTextField.text?.isValidEmail)
        print(!isDuplicateID)
        print(passwordTextField[1].text?.isValidPassword)
        print(passwordTextField[0].text == passwordTextField[1].text)
        print(emailTextField.text?.isValidEmail)
        print(nameTextField.text?.isValidName)
        return false
    }
}
