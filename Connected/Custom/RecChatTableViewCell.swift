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
    
    var audioName: String!
    {
        didSet
        {
            let time = self.audioName.components(separatedBy: "T")
            self.timeLabel.text = time[0]
            self.readLabel.text = String(time[1].prefix(5))
        }
    }
    
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
    
    var second = 0
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        self.messageView.clipsToBounds = true
        self.messageView.layer.masksToBounds = false
        self.waveFormImageView.contentMode = .scaleAspectFit
        self.playbackButton.backgroundColor = .lightGray
        self.playbackButton.isUserInteractionEnabled = false
        self.contentView.layer.shadowRadius = 4
        self.contentView.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.contentView.layer.shadowColor = UIColor.gray.cgColor
        self.contentView.layer.shadowOpacity = 0.2

        self.messageView.layer.cornerRadius = 18.0
        self.messageView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        self.messageView.layer.borderWidth = 0.5
        self.messageView.layer.borderColor = UIColor.lightGray.cgColor

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
                        self.playbackButton.backgroundColor = UIColor(red: 0.82, green: 0.98, blue: 0.92, alpha: 1.00)
                        self.playbackButton.isUserInteractionEnabled = true
                        player.play()
                        timer = Timer.scheduledTimer(timeInterval: TimeInterval(0.1), target: self, selector: #selector(self.updateProgess), userInfo: nil, repeats: true)
                    }
                    else
                    {
                        self.playbackButton.backgroundColor = UIColor(red: 0.82, green: 0.98, blue: 0.92, alpha: 1.00)
                        self.playbackButton.isUserInteractionEnabled = true
                        player = try AVAudioPlayer(data: audio, fileTypeHint: AVFileType.m4a.rawValue)
                        guard let player = player else { return }
                        player.prepareToPlay()
                        player.delegate = self
                        player.volume = 50.0
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
            self.playbackButton.backgroundColor = .lightGray
            self.playbackButton.isUserInteractionEnabled = false
        }
    }
    
    @objc func updateProgess()
    {
        let fullRect = self.waveFormImageView.bounds
        let newWidth = Double(fullRect.size.width) * Double(self.second)/10.0/(self.player!.duration/self.rate)
        let maskLayer = CAShapeLayer()
        let maskRect = CGRect(x: 0.0, y: 0.0, width: newWidth, height: Double(fullRect.size.height))

        let path = CGPath(rect: maskRect, transform: nil)
        maskLayer.path = path

        self.waveFormImageView.layer.mask = maskLayer
        self.second += 1
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
