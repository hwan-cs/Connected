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
    
    var audioURLArray: [AVURLAsset] = []
    
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
            let waveFormAnalyzer = WaveformAnalyzer(audioAssetURL: AVURLAsset(url: self.audioURLArray[indexPath.row]))
            WaveformImageDrawer().waveformImage(
                fromAudioAt: waveFormAnalyzer?.samples(count: 100), with: .init(
                    size: cell.waveFormImageView.bounds.size,
                    style: .gradient([
                                    UIColor(red: 255/255.0, green: 159/255.0, blue: 28/255.0, alpha: 1),
                                    UIColor(red: 255/255.0, green: 191/255.0, blue: 105/255.0, alpha: 1),
                                    UIColor.red]),
                    dampening: .init(percentage: 0.2, sides: .right, easing: { x in pow(x, 4) }),
                    position: .top,
                    verticalScalingFactor: 2))
            { image in
                DispatchQueue.main.async
                {
                    cell.waveFormImageView.image = image
                }
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier:  K.yourChatCellID, for: indexPath) as!  RecChatTableViewCell
        let waveFormAnalyzer = WaveformAnalyzer(audioAssetURL: AVAssetReader(asset: AVAsset(url: self.audioURLArray[indexPath.row])))
        WaveformImageDrawer().waveformImage(
            fromAudioAt: (waveFormAnalyzer?.samples(count: 100))!, with: .init(
                size: cell.waveFormImageView.bounds.size,
                style: .gradient([
                                UIColor(red: 255/255.0, green: 159/255.0, blue: 28/255.0, alpha: 1),
                                UIColor(red: 255/255.0, green: 191/255.0, blue: 105/255.0, alpha: 1),
                                UIColor.red]),
                dampening: .init(percentage: 0.2, sides: .right, easing: { x in pow(x, 4) }),
                position: .top,
                verticalScalingFactor: 2))
        { image in
            DispatchQueue.main.async
            {
                cell.waveFormImageView.image = image
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        self.audioURLArray.count
    }
}
