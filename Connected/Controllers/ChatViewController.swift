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
    
    var audioPulse: PulseAnimation!
    
    var recordingSession: AVAudioSession = AVAudioSession()
    
    var audioRecorder: AVAudioRecorder!
    
    var waveFormView: WaveformLiveView = WaveformLiveView()
    
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
        
        recordingSession = AVAudioSession.sharedInstance()

        do
        {
            try recordingSession.setCategory(.playAndRecord, mode: .voiceChat)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission()
            { [unowned self] allowed in
                DispatchQueue.main.async
                {
                    if allowed
                    {
                        self.loadRecordingUI()
                    }
                    else
                    {
                        print("recording not allowd")
                    }
                }
            }
        }
        catch
        {
            print("some error")
        }
    }
    
    @objc func startPulse()
    {
        audioPulse = PulseAnimation(numberOfPulse: Float.infinity, radius: 75, position: CGPoint(x: self.recordButton.center.x, y: self.stackView.center.y))
        audioPulse.animationDuration = 0.5
        audioPulse.backgroundColor = K.mainColor.cgColor
        self.view.layer.insertSublayer(audioPulse, below: self.view.layer)
        
        startRecording()
        pulse()
//        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(pulse), userInfo: nil, repeats: true)
    }
    
    @objc func pulse()
    {
        let displayLink = CADisplayLink(target: self, selector: #selector(updateWave))
        displayLink.add(to: .current, forMode: .default)
    }
    
    @objc func updateWave()
    {
        audioRecorder.updateMeters()
        let avgPower = audioRecorder.averagePower(forChannel: 0)
        let linear = 1 - pow(10, avgPower / 20)
        
        waveFormView.add(samples: [linear, linear, linear])
    }
    
    @objc func stopPulse()
    {
        timer?.invalidate()
        audioPulse.removeFromSuperlayer()
    }
    
    func loadRecordingUI()
    {
//        waveFormView.center.y = recordButton.center.y - 200
//        waveFormView.center.x = stackView.center.x
        waveFormView.backgroundColor = .clear
        waveFormView.frame = CGRect(origin: CGPoint(x: stackView.center.x-self.recordButton.frame.width, y: stackView.center.y - 200), size: CGSize(width: (self.recordButton.frame.width*2), height: 120.0))
        waveFormView.configuration = waveFormView.configuration.with(
            style: .striped(.init(color: K.mainColor, width: 3, spacing: 3)),
            position: .middle,
            verticalScalingFactor: 3)
        //stackView.addSubview(waveFormView)
        view.addSubview(waveFormView)
    }
    
    func finishRecording(success: Bool)
    {
        audioRecorder.stop()
        audioRecorder = nil

        if success
        {
            self.waveFormView.backgroundColor = .blue
        }
        else
        {
            self.waveFormView.backgroundColor = .red
            // recording failed :(
        }
    }
    
    func startRecording()
    {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("localAudio_\(String(describing: UUID.init(uuidString: "helloworld"))).m4a", conformingTo: .audio)

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do
        {
            audioRecorder = try AVAudioRecorder(url: path, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()
            audioRecorder.isMeteringEnabled = true
            audioRecorder.record()
        }
        catch
        {
            finishRecording(success: false)
        }
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

extension ChatViewController: AVAudioRecorderDelegate
{
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool)
    {
        if !flag
        {
            self.finishRecording(success: false)
        }
    }
}
