//
//  SettingLanguageViewController.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/11/10.
//

import Foundation
import UIKit

class SettingLanguageViewController: UIViewController
{
    @IBOutlet var tableView: UITableView!
    
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
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.backIndicatorImage = backButton?.withTintColor(.black)
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = backButton?.withTintColor(.black)
    }
}

extension SettingLanguageViewController: UITableViewDelegate
{
    
}

extension SettingLanguageViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let image = indexPath.row == 0 ? UIImage(systemName: "character.bubble.fill.ko") : UIImage(systemName: "character.bubble.fill")
        
        var config = cell.defaultContentConfiguration()
        config.image = image
        
        let fullString = NSMutableAttributedString(string: "")

        // create our NSTextAttachment
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(systemName: "checkmark.circle.fill")?.withTintColor(.tintColor)

        // wrap the attachment in its own attributed string so we can append it
        let imageString = NSAttributedString(attachment: imageAttachment)

        // add the NSTextAttachment wrapper to our full string, then add some more text.
        fullString.append(imageString)
        fullString.append(NSAttributedString(string: ""))

        // draw the result in a label
        config.text = indexPath.row == 0 ? "한글" : "English"
        config.secondaryAttributedText = fullString
        cell.contentConfiguration = config
        
        return cell
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

