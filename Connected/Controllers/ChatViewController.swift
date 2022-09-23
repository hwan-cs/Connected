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
    
    var audioURLArray: [String] = []
    
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
        var audio: URL?
        let task = URLSession.shared.downloadTask(with: URL(string: self.audioURLArray[indexPath.row])!)
        { downloadedURL, urlResponse, error in
            guard let downloadedURL = downloadedURL else { return }

            let cachesFolderURL = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let audioFileURL = cachesFolderURL!.appendingPathComponent("yourLocalAudioFile.m4a")
            try? FileManager.default.copyItem(at: downloadedURL, to: audioFileURL)
            audio = audioFileURL
        }
        task.resume()
        
        print(audio!)
        if indexPath.row % 2 == 0
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.myChatCellID, for: indexPath) as! ChatTableViewCell
            DispatchQueue.main.async
            {
                cell.waveFormImageView.waveformAudioURL = audio!
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier:  K.yourChatCellID, for: indexPath) as!  RecChatTableViewCell
        DispatchQueue.main.async
        {
            cell.waveFormImageView.waveformAudioURL = audio!
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        self.audioURLArray.count
    }
}
