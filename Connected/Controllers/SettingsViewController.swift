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
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.safeAreaColorToMainColor()
        self.settingsProfileImg.image = K.myProfileImg!
        self.settingsProfileImg.layer.cornerRadius = 16.0
        self.settingsProfileImg.layer.borderColor = UIColor.white.cgColor
        self.settingsProfileImg.layer.borderWidth = 1.0
        self.settingsProfileName.text = K.myProfileName!
        self.settingsProfileEmail.text = K.myProfileEmail!
        self.settingsProfileUsername.text = K.myProfileUsername!
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
}
