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
    
    @IBOutlet var recordButton: UIButton!
    
    var userViewModel: UserViewModel = UserViewModel()
    
    var disposableBag = Set<AnyCancellable>()
    
    var audioArray: [Data] = []
    
    var audioWaveImageArray = [UIImage]()
    
    let waveformImageDrawer = WaveformImageDrawer()
    
    var timer: Timer?
    
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
        
        recordButton.addTarget(self, action: #selector(startPulse), for: .touchDown)
        recordButton.addTarget(self, action: #selector(stopPulse), for: [.touchUpInside, .touchUpOutside])
        self.setBindings()
    }
    
    @objc func startPulse()
    {
        pulse()
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(pulse), userInfo: nil, repeats: true)
    }
    
    @objc func pulse()
    {
        print(self.recordButton.center.x)
        print(self.recordButton.center.y)
        let pulse = PulseAnimation(numberOfPulse: 2.0, radius: 75, position: CGPoint(x: self.recordButton.center.x, y: self.stackView.center.y))
        pulse.animationDuration = 0.5
        pulse.backgroundColor = K.mainColor.cgColor
        self.view.layer.insertSublayer(pulse, below: self.view.layer)
    }
    
    @objc func stopPulse()
    {
        timer?.invalidate()
    }
}

extension ChatViewController: UITableViewDelegate
{

}

extension ChatViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let myCell = tableView.dequeueReusableCell(withIdentifier: K.myChatCellID, for: indexPath) as! ChatTableViewCell
        let yourCell = tableView.dequeueReusableCell(withIdentifier:  K.yourChatCellID, for: indexPath) as!  RecChatTableViewCell
        self.loadAudio(indexPath.row)
        { url in
            Task.init
            {
                let image = try! await self.waveformImageDrawer.waveformImage(fromAudioAt: url, with: .init(
                    size: myCell.waveFormImageView.bounds.size,
                    style: .striped(.init(color: .gray, width: 3, spacing: 3)),
                    position: .middle,
                    verticalScalingFactor: 1))
                self.audioWaveImageArray.append(image)
                if indexPath.row % 2 == 0
                {
                    DispatchQueue.main.async
                    {
                        print("URL\(indexPath.row):", url)
                        //myCell.waveFormImageView.waveformAudioURL = url
                        myCell.waveFormImageView.image = image
                        myCell.audio = self.audioArray[indexPath.row]
                        
                        let secondImageView = UIImageView(image: image)
                        secondImageView.frame = myCell.waveFormImageView.frame
                        secondImageView.bounds = myCell.waveFormImageView.bounds
                        secondImageView.layer.opacity = 0.3
                        myCell.messageView.addSubview(secondImageView)
                        myCell.selectionStyle = .none
                    }
                }
                else
                {
                    DispatchQueue.main.async
                    {
                        print("URL\(indexPath.row):", url)
                        //yourCell.waveFormImageView.waveformAudioURL = url
                        yourCell.waveFormImageView.image = image
                        yourCell.audio = self.audioArray[indexPath.row]
                        
                        let secondImageView = UIImageView(image: image)
                        secondImageView.frame = yourCell.waveFormImageView.frame
                        secondImageView.bounds = yourCell.waveFormImageView.bounds
                        secondImageView.layer.opacity = 0.3
                        yourCell.messageView.addSubview(secondImageView)
                        yourCell.selectionStyle = .none
                    }
                }
            }
        }
        return indexPath.row % 2 == 0 ? myCell : yourCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        self.audioArray.count
    }
    
    func loadAudio(_ index: Int, completionHandler: @escaping (URL) -> Void)
    {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("localAudio_\(index+1).m4a", conformingTo: .audio)
        guard let url = Bundle.main.url(forResource: "localAudio", withExtension: "m4a") else { fatalError() }
        do
        {
            try self.audioArray[index].write(to: path)
            completionHandler(path)
        }
        catch
        {
            print(error.localizedDescription)
        }
    }

}
