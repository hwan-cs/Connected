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
import FirebaseFirestore
import IQKeyboardManagerSwift

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
    
    var userDataArray: [Data:[Any]] = [:]
    
    let waveformImageDrawer = WaveformImageDrawer()
    
    var timer: Timer?
    
    var audioPulse: PulseAnimation!
    
    var displayLink: CADisplayLink?
    
    var recordingSession: AVAudioSession = AVAudioSession()
    
    var audioRecorder: AVAudioRecorder!
    
    var waveFormView: WaveformLiveView = WaveformLiveView()
    
    var path: URL?
    
    var recepientUID = "NLsm46kThrXznH1daKbBK1U3eyf1"
    
    let db = Firestore.firestore()
    
    var listener: ListenerRegistration?
    
    let myBucketURL =  "gs://connected-3ed2d.appspot.com/"
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.hideKeyboard()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView?.backgroundColor = .clear
        tableView.register(UINib(nibName: K.myChatCellNibName, bundle: nil), forCellReuseIdentifier: K.myChatCellID)
        tableView.register(UINib(nibName: K.yourChatCellNibName, bundle: nil), forCellReuseIdentifier: K.yourChatCellID)
        tableView.register(UINib(nibName: K.myTextCellNibName, bundle: nil), forCellReuseIdentifier: K.myTextCellID)
        tableView.register(UINib(nibName: K.yourTextCellNibName, bundle: nil), forCellReuseIdentifier: K.yourTextCellID)
        
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
        
        self.textView.removeFromSuperview()
        self.growingTextView.delegate = self
        self.growingTextView.translatesAutoresizingMaskIntoConstraints = false
        self.growingTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 8, right: 12)
        self.growingTextView.font = UIFont.systemFont(ofSize: 16.0)
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 64
        self.recordButton.imageView?.image?.withTintColor(K.mainColor)
    }
    
    @objc func startPulse()
    {
        audioPulse = PulseAnimation(numberOfPulse: Float.infinity, radius: 75, position: CGPoint(x: self.recordButton.center.x, y: self.stackView.center.y))
        audioPulse.animationDuration = 0.5
        audioPulse.backgroundColor = K.mainColor.cgColor
        self.view.layer.insertSublayer(audioPulse, below: self.view.layer)
        
        self.loadRecordingUI()
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
        do
        {
            try recordingSession.setCategory(.playAndRecord, mode: .voiceChat, options: [.allowBluetoothA2DP, .mixWithOthers])
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission()
            { [unowned self] allowed in
                DispatchQueue.main.async
                {
                    if allowed
                    {
                        print("mic allowed")
                        self.waveFormView.backgroundColor = .clear
                        self.waveFormView.frame = CGRect(origin: CGPoint(x: self.stackView.center.x-self.recordButton.frame.width, y: self.stackView.center.y - 200), size: CGSize(width: (self.recordButton.frame.width*2), height: 120.0))
                        self.waveFormView.configuration = self.waveFormView.configuration.with(
                            style: .striped(.init(color: K.mainColor, width: 3, spacing: 3)),
                            position: .middle,
                            verticalScalingFactor: 3)
                        //stackView.addSubview(waveFormView)
                        self.view.addSubview(self.waveFormView)
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
    
    func finishRecording(success: Bool)
    {
        audioRecorder.stop()
        audioRecorder = nil
        
        let uuid = Auth.auth().currentUser!.uid
        let metadata = StorageMetadata()
        metadata.contentType = AVFileType.m4a.rawValue
        
        if success
        {
            do
            {
                try recordingSession.setActive(false)
            }
            catch
            {
                print("Cannot set recordingsession to false")
            }
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
                        self.userViewModel?.userDataArray[data] = [true, metadata?.name!]
                        self.db.collection("users").document(uuid).updateData(["change": self.myBucketURL+(metadata?.path)!])
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
    
    @IBAction func onSendButtonTap(_ sender: UIButton)
    {
        self.sendButton.tintColor = .lightGray
        let uuid = Auth.auth().currentUser!.uid
        let metadata = StorageMetadata()
        metadata.contentType = "txt"

        let storageRef = self.storage.reference()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let textRef = storageRef.child("\(uuid)/\(self.recepientUID)/\(formatter.string(from: Date.now)).txt")
        guard let textToSend = self.growingTextView.text.data(using: .utf8) else { return }
        let uploadTask = textRef.putData(textToSend, metadata: metadata)
        { metadata, error in
            if let error = error
            {
                print(error.localizedDescription)
            }
            else
            {
                do
                {
                    self.userViewModel?.userDataArray[textToSend] = [true, metadata?.name]
                    self.db.collection("users").document(uuid).updateData(["change": self.myBucketURL+(metadata?.path)!])
                    self.scrollToBottom()
                }
                catch
                {
                    print(error.localizedDescription)
                }
            }
        }
        self.growingTextView.text = ""
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
        let sortedByValueDictionaryKey = self.userDataArray.sorted(by: { ($0.value[1] as! String).components(separatedBy: ".")[0] < ($1.value[1] as! String).components(separatedBy: ".")[0]}).map({$0.key})
        let sortedByValueDictionaryValue = self.userDataArray.sorted(by: { ($0.value[1] as! String).components(separatedBy: ".")[0] < ($1.value[1] as! String).components(separatedBy: ".")[0]}).map({$0.value})
        
        let isMe = sortedByValueDictionaryValue[indexPath.row][0] as! Bool
        let dataName = sortedByValueDictionaryValue[indexPath.row][1] as! String
        
        let myCell = tableView.dequeueReusableCell(withIdentifier: K.myChatCellID, for: indexPath) as! ChatTableViewCell
        let yourCell = tableView.dequeueReusableCell(withIdentifier:  K.yourChatCellID, for: indexPath) as!  RecChatTableViewCell
        let myTextCell = tableView.dequeueReusableCell(withIdentifier:  K.myTextCellID, for: indexPath) as!  TextChatTableViewCell
        let yourTextCell = tableView.dequeueReusableCell(withIdentifier:  K.yourTextCellID, for: indexPath) as!  RecTextChatTableViewCell

        if dataName.contains(".txt") && isMe
        {
            myTextCell.myChatTextLabel.text = String(data: sortedByValueDictionaryKey[indexPath.row], encoding: .utf8)!
            if myTextCell.myChatTextLabel.text!.count > 13
            {
                myTextCell.messageView.widthAnchor.constraint(equalToConstant: 192).isActive = true
            }
            myTextCell.selectionStyle = .none
            return myTextCell
        }
        else if dataName.contains(".txt") && !isMe
        {
            yourTextCell.myChatTextLabel.text = String(data: sortedByValueDictionaryKey[indexPath.row], encoding: .utf8)!
            if yourTextCell.myChatTextLabel.text!.count > 13
            {
                yourTextCell.messageView.widthAnchor.constraint(equalToConstant: 192).isActive = true
            }
            yourTextCell.selectionStyle = .none
            return yourTextCell
        }
        
        self.loadAudio(indexPath.row)
        { url in
            Task.init
            {
                let color = isMe ? .white : K.mainColor
                let image = try await self.waveformImageDrawer.waveformImage(fromAudioAt: url, with: .init(
                    size: myCell.waveFormImageView.bounds.size,
                    style: .striped(.init(color: color, width: 3, spacing: 3)),
                    position: .middle,
                    verticalScalingFactor: 1))
                if isMe
                {
                    DispatchQueue.main.async
                    {
                        //myCell.waveFormImageView.waveformAudioURL = url
                        myCell.waveFormImageView.image = image
                        myCell.audio = sortedByValueDictionaryKey[indexPath.row]
                        myCell.audioName = sortedByValueDictionaryValue[indexPath.row][1] as? String
                        myCell.selectionStyle = .none
                    }
                }
                else
                {
                    DispatchQueue.main.async
                    {
                        //yourCell.waveFormImageView.waveformAudioURL = url
                        yourCell.waveFormImageView.image = image
                        yourCell.audio = sortedByValueDictionaryKey[indexPath.row]
                        myCell.audioName = sortedByValueDictionaryValue[indexPath.row][1] as? String
                        yourCell.selectionStyle = .none
                    }
                }
            }
        }
        return isMe ? myCell : yourCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        self.userDataArray.count
    }
    
    func loadAudio(_ index: Int, completionHandler: @escaping (URL) -> Void)
    {
        let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("localAudio_\(index+1).m4a", conformingTo: .audio)
        let sortedByValueDictionaryKey = self.userDataArray.sorted(by: { ($0.value[1] as! String).components(separatedBy: ".")[0] < ($1.value[1] as! String).components(separatedBy: ".")[0]}).map({$0.key})
        do
        {
            try sortedByValueDictionaryKey[index].write(to: filePath)
            completionHandler(filePath)
        }
        catch
        {
            print(error.localizedDescription)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        if K.didInit
        {
            return
        }
        if let lastVisibleIndexPath = tableView.indexPathsForVisibleRows?.last
        {
            if indexPath == lastVisibleIndexPath
            {
                self.scrollToBottom()
                let uuid = Auth.auth().currentUser!.uid
                K.didInit = true
                //If recipient is talking to me, add snapshot listener their firdoc
                Task.init
                {
                    let talkingTo = try await self.db.collection("users").document(self.recepientUID).getDocument().data()
                    print(uuid)
                    if !(talkingTo!["talkingTo"] as? String == uuid && K.didInit)
                    {
                        return
                    }
                }
                listener = self.db.collection("users").document(self.recepientUID).addSnapshotListener(
                { documentSnapshot, error in
                    guard documentSnapshot != nil
                    else
                    {
                        print("Error fetching document: \(error!)")
                        return
                    }
                    Task.init
                    {
                        let talkingTo = try await self.db.collection("users").document(self.recepientUID).getDocument().data()
                        let storageRef = self.storage.reference()
                        let myAudioRef = storageRef.child("\(self.recepientUID)/\(uuid)/")
                        let fileName = (talkingTo!["change"] as! String).components(separatedBy: uuid+"/")[1]
                        myAudioRef.storage.reference(forURL: talkingTo!["change"] as! String).getData(maxSize: 1*1024*1024)
                        { data, error in
                            self.userViewModel?.userDataArray[data!] = [false, fileName]
                        }
                    }
                })
            }
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
    func textViewDidChange(_ textView: UITextView)
    {
        if textView.text.count > 0
        {
            self.sendButton.tintColor = K.mainColor
        }
        else
        {
            self.sendButton.tintColor = .lightGray
        }
    }
    
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat)
    {
        print("changed height??")
        UIView.animate(withDuration: 0.2)
        {
            self.view.layoutIfNeeded()
        }
    }
}
