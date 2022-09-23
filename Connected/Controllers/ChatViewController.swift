//
//  ChatViewController.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/09/21.
//

import Foundation
import UIKit
import Combine
import AVFoundation
import DSWaveformImage

class ChatViewController: UIViewController
{
    @IBOutlet var stackView: UIStackView!
    
    @IBOutlet var tableView: UITableView!
    
    var userViewModel: UserViewModel = UserViewModel()
    
    var disposableBag = Set<AnyCancellable>()
    
    var audioURLArray: [URL] = []
    
    var audioWaveImageArray = [UIImage]()
    
    let waveformImageDrawer = WaveformImageDrawer()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView?.backgroundColor = .clear
        tableView.register(UINib(nibName: K.myChatCellNibName, bundle: nil), forCellReuseIdentifier: K.myChatCellID)
        tableView.register(UINib(nibName: K.yourChatCellNibName, bundle: nil), forCellReuseIdentifier: K.yourChatCellID)
        
        stackView.clipsToBounds = true
        stackView.layer.masksToBounds = false
        stackView.layer.shadowColor = UIColor.black.cgColor
        stackView.layer.shadowOffset = CGSize(width: 0, height: 10)
        stackView.layer.shadowOpacity = 0.2
        stackView.layer.shadowRadius = 20.0
        stackView.layer.cornerRadius = 20.0
        stackView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.setBindings()
    }
    
}

extension ChatViewController: UITableViewDelegate
{
    
}

extension ChatViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {        
        if indexPath.row % 2 == 0
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.myChatCellID, for: indexPath) as! ChatTableViewCell
            let url = self.audioURLArray[indexPath.row]
            DispatchQueue.main.async
            {
                print("URL\(indexPath.row):", url)
                cell.waveFormImageView.waveformAudioURL = url
                cell.waveFormImageView.image = self.userViewModel.audioWaveImageArray[indexPath.row]
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier:  K.yourChatCellID, for: indexPath) as!  RecChatTableViewCell
        let url = self.audioURLArray[indexPath.row]
        DispatchQueue.main.async
        {
            print("URL\(indexPath.row):", url)
            cell.waveFormImageView.waveformAudioURL = url
            cell.waveFormImageView.image = self.userViewModel.audioWaveImageArray[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        self.audioURLArray.count
    }
}
