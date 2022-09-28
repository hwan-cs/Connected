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
import FirebaseStorage
import FirebaseAuth
import GrowingTextView

class ChatViewController: UIViewController
{
    @IBOutlet var stackView: UIStackView!

    @IBOutlet var textButton: UIButton!
    
    @IBOutlet var locationButotn: UIButton!
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var recordButton: UIButton!
    
    @IBOutlet var textView: UIView!
    
    @IBOutlet var growingTextView: GrowingTextView!
    
    @IBOutlet var backToMicButton: UIButton!
    
    @IBOutlet var sendButton: UIButton!
    
    var userViewModel: UserViewModel?
    
    let storage = Storage.storage()
    
    var disposableBag = Set<AnyCancellable>()
    
    var audioArray: [Data] = []
    
    let waveformImageDrawer = WaveformImageDrawer()
    
    var timer: Timer?
    
    var audioPulse: PulseAnimation!
    
    var displayLink: CADisplayLink?
    
    var recordingSession: AVAudioSession = AVAudioSession()
    
    var audioRecorder: AVAudioRecorder!
    
    var waveFormView: WaveformLiveView = WaveformLiveView()
    
    var path: URL?
    
    var recepientUID = "NLsm46kThrXznH1daKbBK1U3eyf1"
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.hideKeyboard()
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
        
        self.userViewModel = UserViewModel(Auth.auth().currentUser!.uid, self.recepientUID)
        
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
        
        self.textView.removeFromSuperview()
        self.growingTextView.translatesAutoresizingMaskIntoConstraints = false
        self.growingTextView.textContainerInset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        self.growingTextView.font = UIFont.systemFont(ofSize: 16.0)
    }
    
    @objc func startPulse()
    {
        audioPulse = PulseAnimation(numberOfPulse: Float.infinity, radius: 75, position: CGPoint(x: self.recordButton.center.x, y: self.stackView.center.y))
        audioPulse.animationDuration = 0.5
        audioPulse.backgroundColor = K.mainColor.cgColor
        self.view.layer.insertSublayer(audioPulse, below: self.view.layer)
        view.addSubview(waveFormView)
        startRecording()
        pulse()
    }
    
    @objc func pulse()
    {
        displayLink = CADisplayLink(target: self, selector: #selector(updateWave))
        displayLink!.add(to: .current, forMode: .common)
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
        self.finishRecording(success: true)
        audioPulse.removeFromSuperlayer()
        self.waveFormView.removeFromSuperview()
        displayLink?.invalidate()
        displayLink = nil
    }
    
    func loadRecordingUI()
    {
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
        
        let uuid = Auth.auth().currentUser!.uid
        let metadata = StorageMetadata()
        metadata.contentType = AVFileType.m4a.rawValue
        
        if success
        {
            let storageRef = self.storage.reference()
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone.current
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            let audioRef = storageRef.child("\(uuid)/\(self.recepientUID)/\(formatter.string(from: Date.now)).m4a")
            
            let uploadTask = audioRef.putFile(from: self.path!, metadata: metadata)
            { metadata, error in
                if let error = error
                {
                    print(error.localizedDescription)
                }
                else
                {
                    do
                    {
                        let data = try Data(contentsOf: self.path!)
                        self.userViewModel?.audioName.append((metadata?.name)! )
                        self.userViewModel?.audioArray.append(data)
                    }
                    catch
                    {
                        print(error.localizedDescription)
                    }
                }
            }
        }
        else
        {
            
            // recording failed :(
        }
    }
    
    func startRecording()
    {
        path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(self.recepientUID).m4a", conformingTo: .audio)

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do
        {
            audioRecorder = try AVAudioRecorder(url: self.path!, settings: settings)
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
    
    @IBAction func onTextButotnTap(_ sender: UIButton)
    {
        self.textButton.removeFromSuperview()
        self.locationButotn.removeFromSuperview()
        self.recordButton.removeFromSuperview()
        self.stackView.addArrangedSubview(self.textView)
        self.textView.isHidden = false
        self.textView.isUserInteractionEnabled = true
    }
    
    @IBAction func onLocationButtonTap(_ sender: UIButton)
    {
        
    }
    
    @IBAction func onBackToMicButtonTap(_ sender: UIButton)
    {
        self.textView.removeFromSuperview()
        self.textView.isHidden = true
        self.textView.isUserInteractionEnabled = false
        self.stackView.addArrangedSubview(self.textButton)
        self.stackView.addArrangedSubview(self.recordButton)
        self.stackView.addArrangedSubview(self.locationButotn)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        self.view.endEditing(true)
        return false
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
                let color = indexPath.row % 2 == 0 ? .white : K.mainColor
                let image = try await self.waveformImageDrawer.waveformImage(fromAudioAt: url, with: .init(
                    size: myCell.waveFormImageView.bounds.size,
                    style: .striped(.init(color: color, width: 3, spacing: 3)),
                    position: .middle,
                    verticalScalingFactor: 1))
                if indexPath.row % 2 == 0
                {
                    DispatchQueue.main.async
                    {
                        //myCell.waveFormImageView.waveformAudioURL = url
                        myCell.waveFormImageView.image = image
                        myCell.audio = self.audioArray[indexPath.row]
                        myCell.audioName = self.userViewModel?.audioName[indexPath.row]
                        myCell.selectionStyle = .none
                    }
                }
                else
                {
                    DispatchQueue.main.async
                    {
                        //yourCell.waveFormImageView.waveformAudioURL = url
                        yourCell.waveFormImageView.image = image
                        yourCell.audio = self.audioArray[indexPath.row]
                        yourCell.audioName = self.userViewModel?.audioName[indexPath.row]
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
        let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("localAudio_\(index+1).m4a", conformingTo: .audio)
        do
        {
            try self.audioArray[index].write(to: filePath)
            completionHandler(filePath)
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

extension ChatViewController: GrowingTextViewDelegate
{
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat)
    {
        UIView.animate(withDuration: 0.2)
        {
            self.view.layoutIfNeeded()
        }
    }
}
