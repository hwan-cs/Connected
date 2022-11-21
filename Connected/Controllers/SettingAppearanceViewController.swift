//
//  SettingAppearanceViewController.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/11/10.
//

import Foundation
import UIKit

class SettingAppearanceViewController: UIViewController
{
    @IBOutlet var tableView: UITableView!
    
    var onDismissBlock : ((Bool) -> Void)?
    
    let options = K.lang == "ko" ? ["라이트 모드", "다크 모드"] : ["Light mode", "Dark mode"]
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.safeAreaColorToMainColor()
        self.tableView.backgroundColor = .lightGray
        self.tableView.layer.cornerRadius = 16.0
        self.tableView.layer.borderWidth = 1
        self.tableView.layer.borderColor = UIColor.lightGray.cgColor
        
        let backButton = UIImage(named: "backButton")
        self.navigationController?.navigationBar.tintColor = UIColor(named: "BlackAndWhite")!
        self.navigationController?.navigationBar.backIndicatorImage = backButton?.withTintColor(UIColor(named: "BlackAndWhite")!)
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = backButton?.withTintColor(UIColor(named: "BlackAndWhite")!)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.view.overrideUserInterfaceStyle = K.darkmode ? .dark : .light
    }
}

extension SettingAppearanceViewController: UITableViewDelegate
{
    
}

extension SettingAppearanceViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let image = indexPath.row == 0 ? UIImage(named: "LogoSmall_Light") : UIImage(named: "LogoSmall_Dark")
        
        var config = cell.defaultContentConfiguration()
        config.image = image
        
        let fullString = NSMutableAttributedString(string: "")

        // create our NSTextAttachment
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(systemName: "checkmark.circle.fill")?.withTintColor(UIColor(named: "BlackAndWhite")!)
        // wrap the attachment in its own attributed string so we can append it
        let imageString = NSAttributedString(attachment: imageAttachment)
        fullString.append(imageString)
        fullString.append(NSAttributedString(string: ""))

        // draw the result in a label
        config.text = options[indexPath.row]
        if UserDefaults.standard.bool(forKey: "didAlterSettings")
        {
            if UserDefaults.standard.bool(forKey: "darkmode")
            {
                config.secondaryAttributedText = indexPath.row == 0 ? nil : fullString
            }
            else
            {
                config.secondaryAttributedText = indexPath.row == 0 ? fullString : nil
            }
        }
        else
        {
            config.secondaryAttributedText = indexPath.row == 0 ? nil : fullString
        }
        cell.contentConfiguration = config
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let cell = tableView.cellForRow(at: indexPath)
        var config = cell?.defaultContentConfiguration()
        if config?.secondaryAttributedText != nil
        {
            return
        }
        if !UserDefaults.standard.bool(forKey: "didAlterSettings")
        {
            UserDefaults.standard.set(true, forKey: "didAlterSettings")
        }
        let image = indexPath.row == 0 ? UIImage(named: "LogoSmall_Light") : UIImage(named: "LogoSmall_Dark")
        config?.image = image
        
        let fullString = NSMutableAttributedString(string: "")
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(systemName: "checkmark.circle.fill")?.withTintColor(UIColor(named: "BlackAndWhite")!)

        let imageString = NSAttributedString(attachment: imageAttachment)
        fullString.append(imageString)
        fullString.append(NSAttributedString(string: ""))
        
        var bar = 0
        //when light mode isnt on
        if indexPath.row == 0
        {
            UserDefaults.standard.set(false, forKey: "darkmode")
            config?.text = self.options[indexPath.row]
            self.view.overrideUserInterfaceStyle = .light
            self.navigationController?.navigationBar.scrollEdgeAppearance?.backgroundColor = UIColor(red: 0.020, green: 0.780, blue: 0.510, alpha: 1.0)
            self.navigationController?.view.tintColor = .white
            K.darkmode = false
            self.navigationController?.view.overrideUserInterfaceStyle = K.darkmode ? .dark : .light
            config?.secondaryAttributedText = fullString
            cell!.contentConfiguration = config
            self.onDismissBlock!(true)
            bar = 1
        }
        else
        {
            UserDefaults.standard.set(true, forKey: "darkmode")
            config?.text = self.options[indexPath.row]
            self.view.overrideUserInterfaceStyle = .dark
            self.navigationController?.navigationBar.scrollEdgeAppearance?.backgroundColor = UIColor(red: 0.165, green: 0.325, blue: 0.267, alpha: 1.0)
            self.navigationController?.view.tintColor = .white
            K.darkmode = true
            self.navigationController?.view.overrideUserInterfaceStyle = K.darkmode ? .dark : .light
            config?.secondaryAttributedText = fullString
            cell!.contentConfiguration = config
            self.onDismissBlock!(true)
        }
        let foo = tableView.cellForRow(at: IndexPath(row: bar, section: 0))
        config?.image = bar == 0 ? UIImage(named: "LogoSmall_Light") : UIImage(named: "LogoSmall_Dark")
        config?.text = self.options[bar]
        config?.secondaryAttributedText = NSMutableAttributedString(string: "")
        foo?.contentConfiguration = config
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 64.0
    }
}
