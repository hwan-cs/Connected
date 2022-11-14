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
import LoadingShimmer
import CoreLocation
import GoogleMaps
import GooglePlaces
import UIView_Shimmer

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
    
    var userDataArray: [Data:[AnyHashable]] = [:]
    
    let waveformImageDrawer = WaveformImageDrawer()
    
    var timer: Timer?
    
    var audioPulse: PulseAnimation!
    
    var displayLink: CADisplayLink?
    
    var recordingSession: AVAudioSession = AVAudioSession()
    
    var audioRecorder: AVAudioRecorder!
    
    var waveFormView: WaveformLiveView = WaveformLiveView()
    
    var path: URL?
    
    var recepientUID = ""
    
    let db = Firestore.firestore()
    
    var listener: ListenerRegistration?
    
    var userInfoListener: ListenerRegistration?
    
    let myBucketURL =  "gs://connected-3ed2d.appspot.com/"
    
    var sortedByValueDictionaryKey: [Data] = []
    
    var sortedByValueDictionaryValue: [[AnyHashable]] = [[]]
    
    var locationManager: CLLocationManager?
    
    var mapView: GMSMapView = GMSMapView()
    
    var backgroundView: UIView = UIView()
    
    var minMaxBtn: UIButton = UIButton()
    
    var markers = [GMSMarker]()
    
    var backgroundViewHeightConstraint: NSLayoutConstraint?
    
    var backgroundViewTrailingConstraint: NSLayoutConstraint?
    
    var backgroundViewLeadingConstraint: NSLayoutConstraint?
    
    var backgroundViewTopAnchorConstraint: NSLayoutConstraint?
    
    var isSharingLocation = false
    
    var recMapView: GMSMapView = GMSMapView()
    
    var recBackgroundView: UIView = UIView()
    
    var recMinMaxBtn: UIButton = UIButton()
    
    var recBackgroundViewHeightConstraint: NSLayoutConstraint?
    
    var recBackgroundViewTrailingConstraint: NSLayoutConstraint?
    
    var recBackgroundViewLeadingConstraint: NSLayoutConstraint?
    
    var recBackgroundViewTopAnchorConstraint: NSLayoutConstraint?
    
    let uuid = Auth.auth().currentUser?.uid
    
    var myName: String?
    
    var idx: Int?
    
    var sharingLocation = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        K.frameHeight = self.view.frame.origin.y
        self.chatVCHideKeyboard()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        tableView.delegate = self
        tableView.tableHeaderView?.backgroundColor = UIColor(named: "BackgroundColor2")
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
        
        recordingSession = AVAudioSession.sharedInstance()
        
        self.textView.removeFromSuperview()
        self.growingTextView.delegate = self
        self.growingTextView.translatesAutoresizingMaskIntoConstraints = false
        self.growingTextView.textContainerInset = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        self.growingTextView.font = UIFont.systemFont(ofSize: 16.0)
        self.tableView.estimatedRowHeight = 64
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        
        self.sharingLocation = ChatRoomViewController.sortedByValueDictionaryValue[self.idx!][3] as! Bool
        
        self.navigationController?.navigationBar.backItem?.backBarButtonItem?.tintColor = K.mainColor
        Task.init
        {
            let data = try await self.db.collection("users").document(self.recepientUID).getDocument().data()
            self.navigationController?.navigationBar.topItem?.title = data!["name"] as? String
            AppDelegate.receiverFCMToken = data!["fcmToken"] as? String
        }
        
        Task.init
        {
            if let dict = try await self.db.collection("userInfo").document(uuid!).getDocument().data()?["chatRoom"] as? [String:[AnyHashable]]
            {
                var temp = dict
                if temp[self.recepientUID] != nil
                {
                    temp[self.recepientUID]![2] = 0
                    try await self.db.collection("userInfo").document(uuid!).updateData(["chatRoom" : temp])
                }
            }
            try await self.db.collection("users").document(uuid!).updateData(["talkingTo": self.recepientUID])
            if let mData = try await self.db.collection("users").document(uuid!).getDocument().data()
            {
                self.myName = mData["name"] as? String
                if (self.sharingLocation)
                {
                    self.locationManager?.requestAlwaysAuthorization()
                    mapView.delegate = self
                    mapView.isMyLocationEnabled = true
                    if let location = self.locationManager?.location
                    {
                        let camera = GMSCameraPosition.camera(withLatitude: (location.coordinate.latitude), longitude: (location.coordinate.longitude), zoom: 17.0)
                        mapView.camera = camera
                    }
                    self.loadMap()
                    self.locationButotn.tintColor = .gray
                }
            }
            if let data = try await self.db.collection("userInfo").document(self.recepientUID).getDocument().data()?["chatRoom"] as? [String:[AnyHashable]]
            {
                self.isSharingLocation = data[self.uuid!]![3] as! Bool
                if self.isSharingLocation
                {
                    self.initRecMapView()
                    if let user = try await self.db.collection("users").document(self.recepientUID).getDocument().data()
                    {
                        if let location = user["location"] as? GeoPoint
                        {
                            let camera = GMSCameraPosition.camera(withLatitude: (location.latitude), longitude: (location.longitude), zoom: 17.0)
                            recMapView.camera = camera
                        }
                    }
                }
            }
        }
        self.setupDataSource()
    }
    
    func setupDataSource()
    {
        self.userViewModel?.dataSource = UITableViewDiffableDataSource<Data, [AnyHashable]>(tableView: tableView, cellProvider:
        { tableView, indexPath, itemIdentifier in
            let isMe = self.sortedByValueDictionaryValue[indexPath.row][0] as! Bool
            let dataName = self.sortedByValueDictionaryValue[indexPath.row][1] as! String
            
            let myCell = tableView.dequeueReusableCell(withIdentifier: K.myChatCellID, for: indexPath) as! ChatTableViewCell
            let yourCell = tableView.dequeueReusableCell(withIdentifier:  K.yourChatCellID, for: indexPath) as!  RecChatTableViewCell
            let myTextCell = tableView.dequeueReusableCell(withIdentifier:  K.myTextCellID, for: indexPath) as!  TextChatTableViewCell
            let yourTextCell = tableView.dequeueReusableCell(withIdentifier:  K.yourTextCellID, for: indexPath) as!  RecTextChatTableViewCell

            if dataName.contains(".txt") && isMe
            {
                myTextCell.myChatTextLabel.text = String(data: self.sortedByValueDictionaryKey[indexPath.row], encoding: .utf8)!
                myTextCell.messageView.sizeToFit()
                myTextCell.messageView.layoutIfNeeded()
                myTextCell.txtName = self.sortedByValueDictionaryValue[indexPath.row][1] as? String
                myTextCell.selectionStyle = .none
                return myTextCell
            }
            else if dataName.contains(".txt") && !isMe
            {
                yourTextCell.myChatTextLabel.text = String(data: self.sortedByValueDictionaryKey[indexPath.row], encoding: .utf8)!
                yourTextCell.messageView.sizeToFit()
                yourTextCell.messageView.layoutIfNeeded()
                yourTextCell.txtName = self.sortedByValueDictionaryValue[indexPath.row][1] as? String
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
                        myCell.waveFormImageView.image = image
                        myCell.audio = self.sortedByValueDictionaryKey[indexPath.row]
                        myCell.audioName = self.sortedByValueDictionaryValue[indexPath.row][1] as? String
                        myCell.selectionStyle = .none
                    }
                    else
                    {
                        yourCell.waveFormImageView.image = image
                        yourCell.audio = self.sortedByValueDictionaryKey[indexPath.row]
                        yourCell.audioName = self.sortedByValueDictionaryValue[indexPath.row][1] as? String
                        yourCell.selectionStyle = .none
                    }
                }
            }
            return isMe ? myCell : yourCell
        })
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.navigationController?.navigationBar.prefersLargeTitles = false
        let backButton = UIImage(named: "backButton")
        self.navigationController?.navigationBar.tintColor = UIColor(named: "BlackAndWhite")!
        self.navigationController?.navigationBar.backIndicatorImage = backButton?.withTintColor(.black)
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = backButton?.withTintColor(.black)
    }

    override func viewWillDisappear(_ animated: Bool)
    {
        if K.didSendAnything
        {
            Task.init
            {
                let talkingTo = try await self.db.collection("users").document(self.uuid!).getDocument().data()
                let rec = talkingTo!["talkingTo"] as? String
                if let dict = try await self.db.collection("userInfo").document(self.uuid!).getDocument().data()?["chatRoom"] as? [String:[AnyHashable]]
                {
                    var temp = dict
                    if let rdict = try await self.db.collection("userInfo").document(self.recepientUID).getDocument().data()?["chatRoom"] as? [String:[AnyHashable]]
                    {
                        temp[self.recepientUID]![0] = rdict[self.uuid!]![0]
                        temp[self.recepientUID]![1] = rdict[self.uuid!]![1]
                        try await self.db.collection("userInfo").document(self.uuid!).updateData(["chatRoom" : temp])
                    }
                }
                try await self.db.collection("users").document(self.uuid!).updateData(["talkingTo": ""])
            }
        }
        for avp in K.allAudioPlayers
        {
            avp.stop()
        }
        K.didInit = false
        K.didSendAnything = false
        self.listener = nil
        self.navigationController?.navigationBar.prefersLargeTitles = true
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
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(recordingStoppedEarlier), userInfo: nil, repeats: true)
    }
    
    //Recording stopped before maximum duration time (60 seconds)
    @objc func recordingStoppedEarlier()
    {
        if !self.audioRecorder.isRecording
        {
            self.stopPulse()
        }
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
        timer = nil
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
            try recordingSession.setCategory(.playAndRecord, mode: .voiceChat, options: [.allowBluetoothA2DP, .mixWithOthers, .allowBluetooth])
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission()
            { [unowned self] allowed in
                DispatchQueue.main.async
                {
                    if allowed
                    {
                        print("mic allowed")
                        self.waveFormView.backgroundColor = .clear
                        self.waveFormView.frame = CGRect(origin: CGPoint(x: self.stackView.center.x-self.recordButton.frame.width, y: self.stackView.center.y - self.stackView.frame.height/2 - 120), size: CGSize(width: (self.recordButton.frame.width*2), height: 120.0))
                        self.waveFormView.configuration = self.waveFormView.configuration.with(
                            style: .striped(.init(color: .systemBlue, width: 3, spacing: 3)),
                            position: .bottom,
                            verticalScalingFactor: 6.5)
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
        if self.audioRecorder == nil
        {
            return
        }
        audioRecorder.stop()
        audioRecorder = nil
        
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
            let now = formatter.string(from: Date.now)
            let audioRef = storageRef.child("\(self.uuid!)/\(self.recepientUID)/\(now).m4a")
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
                        Task.init
                        {
                            let data = try Data(contentsOf: self.path!)
                            self.userViewModel?.userDataArray[data] = [true, metadata?.name!]
                            let talkingTo = try await self.db.collection("users").document(self.recepientUID).getDocument().data()
                            let rec = talkingTo!["talkingTo"] as? String
                            if rec == self.uuid!
                            {
                                try await self.db.collection("users").document(self.uuid!).updateData(["change": self.myBucketURL+(metadata?.path)!])
                            }
                            if let dict = try await self.db.collection("userInfo").document(self.recepientUID).getDocument().data()?["chatRoom"] as? [String:[AnyHashable]]
                            {
                                if let unreadCount = dict[self.uuid!]![2] as? Int
                                {
                                    var temp = dict
                                    temp[self.uuid!]![0] = "waveform"
                                    temp[self.uuid!]![1] = now
                                    if rec != self.uuid!
                                    {
                                        temp[self.uuid!]![2] = unreadCount+1
                                    }
                                    try await self.db.collection("userInfo").document(self.recepientUID).updateData(["chatRoom" : temp])
                                    K.didSendAnything = true
                                }
                            }
                        }
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
            print("recording failed")
        }
        if AppDelegate.receiverFCMToken != nil
        {
            self.sendMessageTouser(to: AppDelegate.receiverFCMToken!, title: self.myName!, body: "녹음 메세지")
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
            audioRecorder.record(forDuration: 60.0)
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
        if self.locationButotn.tintColor == .gray
        {
            self.locationButotn.tintColor = K.mainColor
            if self.recBackgroundView.isDescendant(of: self.view)
            {
                self.recBackgroundViewTopAnchorConstraint?.isActive = false
                self.recBackgroundViewTopAnchorConstraint = NSLayoutConstraint(item: self.recBackgroundView, attribute: .top, relatedBy: .equal, toItem: self.tableView, attribute: .top, multiplier: 1.0, constant: 8.0)
                self.recBackgroundViewTopAnchorConstraint?.isActive = true
            }
            self.backgroundView.removeFromSuperview()
            self.view.layoutIfNeeded()
        }
        else
        {
            self.locationManager?.requestAlwaysAuthorization()
            mapView.delegate = self
            mapView.isMyLocationEnabled = true
            if let location = locationManager?.location
            {
                let camera = GMSCameraPosition.camera(withLatitude: (location.coordinate.latitude), longitude: (location.coordinate.longitude), zoom: 17.0)
                mapView.camera = camera
            }
            self.locationButotn.tintColor = .gray
            if self.recBackgroundView.isDescendant(of: self.view)
            {
                self.recBackgroundViewTopAnchorConstraint?.isActive = false
                self.recBackgroundViewTopAnchorConstraint = NSLayoutConstraint(item: self.recBackgroundView, attribute: .top, relatedBy: .equal, toItem: self.tableView, attribute: .top, multiplier: 1.0, constant: 162)
                self.recBackgroundViewTopAnchorConstraint?.isActive = true
            }
            self.view.layoutIfNeeded()
            self.loadMap()
        }
        Task.init
        {
            if let dict = try await self.db.collection("userInfo").document(self.uuid!).getDocument().data()?["chatRoom"] as? [String:[AnyHashable]]
            {
                var temp = dict
                temp[self.recepientUID]![3] = self.locationButotn.tintColor == .gray
                try await self.db.collection("userInfo").document(self.uuid!).updateData(["chatRoom" : temp])
            }
        }
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
        let metadata = StorageMetadata()
        metadata.contentType = "txt"

        let storageRef = self.storage.reference()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let now = Date.now
        let formatted = formatter.string(from: now)
        let textRef = storageRef.child("\(self.uuid!)/\(self.recepientUID)/\(formatted).txt")
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
                    var foo = self.growingTextView.text!
                    if foo == "waveform"
                    {
                        foo = "waveform_"
                    }
                    //update unreadcount for recipient
                    Task.init
                    {
                        let formatter = DateFormatter()
                        formatter.timeZone = TimeZone.current
                        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                        let now = formatter.string(from: Date.now)
                        let talkingTo = try await self.db.collection("users").document(self.recepientUID).getDocument().data()
                        let rec = talkingTo!["talkingTo"] as? String
                        if rec == self.uuid!
                        {
                            try await self.db.collection("users").document(self.uuid!).updateData(["change": self.myBucketURL+(metadata?.path)!])
                        }
                        if let dict = try await self.db.collection("userInfo").document(self.recepientUID).getDocument().data()?["chatRoom"] as? [String:[AnyHashable]]
                        {
                            if let unreadCount = dict[self.uuid!]![2] as? Int
                            {
                                var temp = dict
                                temp[self.uuid!]![0] = String(data: textToSend, encoding: .utf8)
                                temp[self.uuid!]![1] = now
                                if rec != self.uuid!
                                {
                                    temp[self.uuid!]![2] = unreadCount+1
                                }
                                try await self.db.collection("userInfo").document(self.recepientUID).updateData(["chatRoom" : temp])
                                K.didSendAnything = true
                            }
                        }
                    }
                }
                catch
                {
                    print(error.localizedDescription)
                }
            }
        }
        if AppDelegate.receiverFCMToken != nil
        {
            self.sendMessageTouser(to: AppDelegate.receiverFCMToken!, title: self.myName!, body: self.growingTextView.text!)
        }
        self.growingTextView.text = ""
    }
    
    func loadMap()
    {
        self.initMapView()
        self.view.layoutIfNeeded()
        Task.init
        {
            try await self.db.collection("users").document(self.uuid!).updateData(["isSharingLocation": true])
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        self.view.endEditing(true)
        return false
    }
    
    func sendMessageTouser(to token: String, title: String, body: String)
    {
        print("sendMessageTouser()")
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = ["to" : token,
                                           "notification" : ["title" : title, "body" : body],
                                           "data" : ["user" : "test_id"]
        ]
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(AppDelegate.legacyServerKey)", forHTTPHeaderField: "Authorization")
        let task =  URLSession.shared.dataTask(with: request as URLRequest)
        { (data, response, error) in
            do
            {
                if let jsonData = data
                {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject]
                    {
                        print("Received data:\n\(jsonDataDict))")
                    }
                }
            }
            catch let err as NSError
            {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
}

extension ChatViewController: UITableViewDelegate
{
    func loadAudio(_ index: Int, completionHandler: @escaping (URL) -> Void)
    {
        let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("localAudio_\(index+1).m4a", conformingTo: .audio)
        do
        {
            try self.sortedByValueDictionaryKey[index].write(to: filePath)
            completionHandler(filePath)
        }
        catch
        {
            print(error.localizedDescription)
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        if listener != nil
        {
            return
        }
        if let lastVisibleIndexPath = tableView.indexPathsForVisibleRows?.last
        {
            if indexPath == lastVisibleIndexPath
            {
                print(self.recepientUID)
                //If recipient is talking to me, add snapshot listener their firdoc
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
                        let talkingTo = documentSnapshot?.data()
                        let storageRef = self.storage.reference()
                        let myAudioRef = storageRef.child("\(self.recepientUID)/\(self.uuid!)/")
                        let foobar = (talkingTo!["change"] as! String)
                        if foobar != ""
                        {
                            let fileName = foobar.components(separatedBy: self.uuid!+"/")[1]
                            if !self.userDataArray.values.contains(where: { value in
                                value == [false, fileName]
                            })
                            {
                                myAudioRef.storage.reference(forURL: talkingTo!["change"] as! String).getData(maxSize: 5*1024*1024)
                                { data, error in
                                    self.userViewModel?.userDataArray[data!] = [false, fileName]
                                }
                            }
                        }
                        let marker = GMSMarker()
                        let loc = talkingTo!["location"] as! GeoPoint
                        marker.position = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
                        if self.markers.count > 0
                        {
                            self.markers[0].map = nil
                            self.markers.remove(at: 0)
                            self.markers.append(marker)
                        }
                        else
                        {
                            self.markers.append(marker)
                        }
                        marker.map = self.recMapView
                        let camera = GMSCameraPosition.camera(withLatitude: (loc.latitude), longitude: (loc.longitude), zoom: 17.0)
                        self.recMapView.camera = camera
                    }
                })
                
                userInfoListener = self.db.collection("userInfo").document(self.recepientUID).addSnapshotListener(
                    { documentSnapshot, error in
                        guard documentSnapshot != nil
                        else
                        {
                            print("Error fetching document: \(error!)")
                            return
                        }
                        Task.init
                        {
                            if let data = documentSnapshot?.data()
                            {
                                if let chatRooms = data["chatRoom"] as? [String:[AnyHashable]]
                                {
                                    print(chatRooms)
                                    if (chatRooms[self.uuid!]![3] as! Bool)
                                    {
                                        if !self.recBackgroundView.isDescendant(of: self.view)
                                        {
                                            self.initRecMapView()
                                        }
                                    }
                                    else
                                    {
                                        self.recBackgroundView.removeFromSuperview()
                                    }
                                }
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
        UIView.animate(withDuration: 0.2)
        {
            self.view.layoutIfNeeded()
        }
    }
}

//MARK: - CLLocation delegate methods
extension ChatViewController: CLLocationManagerDelegate
{
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager)
    {
        if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse
        {
            locationManager?.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        //change so that update only if sharinglocation is true
        if let location = locations.first
        {
            self.db.collection("users").document(uuid!).updateData(["location": GeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)])
        }
    }
}

extension ChatViewController: GMSMapViewDelegate
{
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker)
    {
        
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool
    {
        return true
    }
}

