//
//  RecChatTableViewCell.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/09/21.
//

import UIKit
import DSWaveformImage
import AVFoundation
import Cache
import UIView_Shimmer
import AMPopTip
import Speech

class RecChatTableViewCell: UITableViewCell, ShimmeringViewProtocol
{

    @IBOutlet var messageView: UIView!
    
    @IBOutlet var waveFormImageView: WaveformImageView!
    
    @IBOutlet var playButton: UIButton!
    
    @IBOutlet var timeLabel: UILabel!
    
    @IBOutlet var readLabel: UILabel!
    
    @IBOutlet var playbackButton: UIButton!
    
    @IBOutlet var playbackLabel: UILabel!
    
    var audio: Data?
    
    let formatter = DateFormatter()
    
    var audioName: String!
    {
        didSet
        {
            let time = self.audioName.components(separatedBy: "T")
            formatter.dateFormat = "yyyy-MM-dd"
            let date = formatter.date(from: time[0])
            self.date = formatter.string(from: date!)
            formatter.dateFormat = K.lang == "ko" ? "MM월 dd일" : "MMMM dd"
            formatter.locale = Locale(identifier: K.lang)
            self.timeLabel.text = formatter.string(from: date!)
            self.readLabel.text = String(time[1].prefix(5))
            formatter.dateFormat = "HH:mm:ssZ"
            self.time = formatter.string(from: formatter.date(from: time[1].components(separatedBy: ".")[0])!)
        }
    }
    
    var date: String?
    
    var time: String?
    
    let infoPopTip = PopTip()
    
    var shimmeringAnimatedItems: [UIView]
    {
        [
            messageView,
            waveFormImageView,
            playButton,
            timeLabel,
            readLabel,
            playbackButton,
            playbackLabel
        ]
    }
    
    var player: AVAudioPlayer?
    
    var playerItem: CachingPlayerItem?
    
    weak var timer: Timer?
    
    var rate = 1.0
    
    var second = 0.0
    
    var task : SFSpeechRecognitionTask?
    
    let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: K.lang))!
    
    var request: SFSpeechURLRecognitionRequest?
    
    var filePath: URL?
    
    var onErrorBlock: ((SRError) -> Void)?
    
    var transcription = PopTip()
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        self.messageView.layer.masksToBounds = false
        self.waveFormImageView.contentMode = .scaleAspectFit
        self.waveFormImageView.isUserInteractionEnabled = true
        self.playbackButton.backgroundColor = .lightGray
        self.playbackButton.isUserInteractionEnabled = false
        self.contentView.layer.shadowRadius = 2
        self.contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.contentView.layer.shadowColor = UIColor.gray.cgColor
        self.contentView.layer.shadowOpacity = 0.2

        self.messageView.layer.cornerRadius = 18.0
        self.messageView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        self.messageView.layer.borderWidth = 0.5
        self.messageView.layer.borderColor = UIColor.lightGray.cgColor
        
        self.infoPopTip.bubbleColor = UIColor.gray
        self.infoPopTip.shouldDismissOnTap = true
        self.timeLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapTimeLabel(tapGestureRecognizer:))))
        self.readLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapDateLabel(tapGestureRecognizer:))))
        self.waveFormImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapWaveformImage(tapGestureRecognizer:))))
    }
    
    @objc func didTapTimeLabel(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let lbl = tapGestureRecognizer.view as! UILabel
        if infoPopTip.isVisible
        {
            infoPopTip.hide()
        }
        infoPopTip.show(text: self.date!, direction: .right, maxWidth: 200, in: self.contentView, from: lbl.frame)
    }
    
    @objc func didTapDateLabel(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let lbl = tapGestureRecognizer.view as! UILabel
        if infoPopTip.isVisible
        {
            infoPopTip.hide()
        }
        infoPopTip.show(text: self.time!, direction: .right, maxWidth: 200, in: self.contentView, from: lbl.frame)
    }
    
    @objc func didTapWaveformImage(tapGestureRecognizer: UITapGestureRecognizer)
    {
        self.requestPermission()
        self.startSpeechRecognition
        { result in
            self.transcription.bubbleColor = .gray
            self.transcription.shouldDismissOnTap = true
            self.transcription.show(text: result, direction: .up, maxWidth: 200, in: self.contentView, from: self.messageView.frame)
        }
    }
    
    func requestPermission()
    {
        SFSpeechRecognizer.requestAuthorization
        { authState in
            OperationQueue.main.addOperation
            {
                if authState == .authorized
                {
                    self.loadAudio()
                }
                else if authState == .denied
                {
                    self.onErrorBlock!(.denied)
                }
                else if authState == .notDetermined
                {
                    self.onErrorBlock!(.notDetermined)
                }
                else if authState == .restricted
                {
                    self.onErrorBlock!(.restricted)
                }
            }
        }
    }
    
    func startSpeechRecognition(completionHandler: @escaping (String) -> Void)
    {
        guard let path = self.filePath else { return }
        self.request = SFSpeechURLRecognitionRequest(url: path)
        self.request!.shouldReportPartialResults = true
        self.speechRecognizer.defaultTaskHint = .dictation
        if (self.speechRecognizer.isAvailable)
        {
            task = self.speechRecognizer.recognitionTask(with: self.request!, resultHandler:
            { result, error in
                guard error == nil else
                {
                    print("Error: \(error!)")
                    return
                }
                print("doing")
                guard let result = result else { print("fail");  return }
                print("result: \(result.bestTranscription.formattedString)")
                completionHandler(result.bestTranscription.formattedString)
            })
        }
        else
        {
            print("Device doesn't support speech recognition")
        }
    }
    
    func loadAudio()
    {
        self.filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("localAudio_\(self.audioName ?? "nil").m4a", conformingTo: .audio)
        do
        {
            try self.audio!.write(to: filePath!)
        }
        catch
        {
            print(error.localizedDescription)
        }
    }

    @IBAction func didTapPlayButton(_ sender: UIButton)
    {
        let shadowImage = UIImageView(image: self.waveFormImageView.image?.withTintColor(K.mainColor))
        shadowImage.frame = self.waveFormImageView.frame
        shadowImage.bounds = self.waveFormImageView.bounds
        shadowImage.layer.opacity = 0.2
        self.messageView.addSubview(shadowImage)
        if self.playButton.currentImage == UIImage(named: "Play.svg")
        {
            self.playButton.setImage(UIImage(named: "Stop-2-1.svg"), for: .normal)
            if let audio = audio
            {
                do
                {
                    if let player = player
                    {
                        self.playbackButton.backgroundColor = UIColor(red: 0.02, green: 0.78, blue: 0.51, alpha: 1.00)
                        self.playbackButton.isUserInteractionEnabled = true
                        player.play()
                        timer = Timer.scheduledTimer(timeInterval: TimeInterval(0.1), target: self, selector: #selector(self.updateProgess), userInfo: nil, repeats: true)
                    }
                    else
                    {
                        self.playbackButton.backgroundColor = UIColor(red: 0.02, green: 0.78, blue: 0.51, alpha: 1.00)
                        self.playbackButton.isUserInteractionEnabled = true
                        player = try AVAudioPlayer(data: audio, fileTypeHint: AVFileType.m4a.rawValue)
                        guard let player = player else { return }
                        K.allAudioPlayers.append(player)
                        player.prepareToPlay()
                        player.delegate = self
                        player.volume = 50.0
                        player.enableRate = true
                        player.play()
                        timer = Timer.scheduledTimer(timeInterval: TimeInterval(0.1), target: self, selector: #selector(self.updateProgess), userInfo: nil, repeats: true)
                    }
                }
                catch
                {
                    print(error.localizedDescription)
                }
            }
        }
        else
        {
            player?.pause()
            self.playButton.setImage(UIImage(named: "Play.svg"), for: .normal)
            timer?.invalidate()
            self.playbackButton.tintColor = .lightGray
            self.playbackButton.isUserInteractionEnabled = false
        }
    }
    
    @objc func updateProgess()
    {
        let fullRect = self.waveFormImageView.bounds
        let newWidth = Double(fullRect.size.width) * ((self.second/10.0)/self.player!.duration)
        let maskLayer = CAShapeLayer()
        let maskRect = CGRect(x: 0.0, y: 0.0, width: newWidth, height: Double(fullRect.size.height))

        let path = CGPath(rect: maskRect, transform: nil)
        maskLayer.path = path

        self.waveFormImageView.layer.mask = maskLayer
        self.second += self.rate
    }
    
    @IBAction func onPlaybackButtonTap(_ sender: UIButton)
    {
        switch sender.tag
        {
        case 1:
            self.player?.rate = 1.5
            self.playbackLabel.text = "1.5x"
            self.rate = 1.5
            sender.tag = 2
        case 2:
            self.player?.rate = 2
            self.playbackLabel.text = "2x"
            self.rate = 2.0
            sender.tag = 3
        default:
            self.player?.rate = 1
            self.playbackLabel.text = "1x"
            self.rate = 1.0
            sender.tag = 1
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

extension RecChatTableViewCell: AVAudioPlayerDelegate
{
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool)
    {
        if flag
        {
            print("finished")
            player.stop()
            player.currentTime = 0
            self.second = 0
            self.playButton.setImage(UIImage(named: "Play.svg"), for: .normal)
            timer?.invalidate()
            timer = nil
            self.playbackButton.backgroundColor = .lightGray
            self.playbackButton.isUserInteractionEnabled = false
        }
        else
        {
            print("unsuccessful")
        }
    }
}
