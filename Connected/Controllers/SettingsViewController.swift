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

    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.navigationController?.navigationBar.topItem?.title = "설정"
        self.navigationController?.navigationBar.backgroundColor = K.mainColor
        let barButtonItem = UIBarButtonItem(title: "로그아웃", style: .done, target: self, action: #selector(logOut))
        barButtonItem.tintColor = .black
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
            print("signed out")
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
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func didTapLanguage(_ sender: UIButton)
    {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LanguageVC") as! SettingLanguageViewController
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func didTapNotification(_ sender: UIButton)
    {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SettingNotificationVC") as! SettingNotificationViewController
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
