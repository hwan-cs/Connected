//
//  SettingsViewController.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/11/08.
//

import Foundation
import UIKit
import Cache
import FirebaseAuth

class SettingsViewController: UIViewController
{
    
    @IBOutlet var settingsProfileImg: UIImageView!
    
    @IBOutlet var settingsProfileName: UILabel!
    
    @IBOutlet var settingsProfileEmail: UILabel!
    
    @IBOutlet var settingsProfileUsername: UILabel!

    @IBOutlet var appearance: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.view.overrideUserInterfaceStyle = K.darkmode ? .dark : .light
        self.navigationController?.navigationBar.topItem?.title = K.lang == "ko" ? "설정" : "Setting"
        self.navigationController?.navigationBar.backgroundColor = K.mainColor
        let barButtonItem = UIBarButtonItem(title: K.lang == "ko" ? "로그아웃" : "Log out", style: .done, target: self, action: #selector(logOut))
        barButtonItem.tintColor = UIColor(named: "BlackAndWhite")
        self.tabBarController?.navigationItem.rightBarButtonItem = barButtonItem
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.safeAreaColorToMainColor()
        self.settingsProfileImg.image = K.myProfileImg != nil ? K.myProfileImg : UIImage(named: "Friend_Inactive")
        self.settingsProfileImg.layer.cornerRadius = 16.0
        self.settingsProfileImg.layer.borderColor = UIColor.white.cgColor
        self.settingsProfileImg.layer.borderWidth = 1.0
        self.settingsProfileName.text = K.myProfileName!
        self.settingsProfileEmail.text = K.myProfileEmail!
        self.settingsProfileUsername.text = K.myProfileUsername!
    }
    
    @objc func logOut()
    {
        do
        {
            try Auth.auth().signOut()
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "InitialNavigationController") as! UINavigationController
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            windowScene?.windows.first?.rootViewController = vc
            windowScene?.windows.first?.makeKeyAndVisible()
        }
        catch
        {
            print("Could not sign out")
        }
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue)
    {
        print("dd")
    }
    
    @IBAction func didTapAppearance(_ sender: UIButton)
    {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AppearanceVC") as! SettingAppearanceViewController
        vc.modalPresentationStyle = .fullScreen
        vc.onDismissBlock =
        {
            success in
            if success
            {
                self.view.overrideUserInterfaceStyle = K.darkmode ? .dark : .light
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func didTapAccount(_ sender: UIButton)
    {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SettingAccountVC") as! SettingAccountViewController
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func didTapEtc(_ sender: UIButton)
    {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SettingEtcVC") as! SettingEtcViewController
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
