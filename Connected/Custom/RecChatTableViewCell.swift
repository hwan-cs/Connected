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

class RecChatTableViewCell: UITableViewCell
{

    @IBOutlet var messageView: UIView!
    
    @IBOutlet var waveFormImageView: WaveformImageView!
    
    @IBOutlet var playButton: UIButton!
    
    @IBOutlet var timeLabel: UILabel!
    
    @IBOutlet var readLabel: UILabel!
    
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
    
    var player: AVAudioPlayer?
    
    var playerItem: CachingPlayerItem?
    
    weak var timer: Timer?
    
    var second = 0
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.messageView.clipsToBounds = true
        self.messageView.layer.masksToBounds = false
        self.waveFormImageView.contentMode = .scaleAspectFit
        self.contentView.layer.shadowRadius = 4
        self.contentView.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.contentView.layer.shadowColor = UIColor.gray.cgColor
        self.contentView.layer.shadowOpacity = 0.2

        self.messageView.roundCorners(topLeft: 16, topRight: 24, bottomLeft: 0, bottomRight: 24)
        
        let borderLayer = CAShapeLayer()
        borderLayer.path = (self.messageView.layer.mask! as! CAShapeLayer).path! // Reuse the Bezier path
        borderLayer.strokeColor = UIColor(red: 0.91, green: 0.92, blue: 0.94, alpha: 1.00).cgColor
        borderLayer.shadowRadius = 24
        borderLayer.shadowOffset = CGSize(width: 0, height: 8)
        borderLayer.shadowColor = UIColor.black.cgColor
        borderLayer.shadowOpacity = 0.2
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.lineWidth = 1
        borderLayer.frame = self.messageView.bounds
        self.messageView.layer.addSublayer(borderLayer)

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
                        player.play()
                        timer = Timer.scheduledTimer(timeInterval: TimeInterval(0.1), target: self, selector: #selector(self.updateProgess), userInfo: nil, repeats: true)
                    }
                    else
                    {
                        player = try AVAudioPlayer(data: audio, fileTypeHint: AVFileType.m4a.rawValue)
                        guard let player = player else { return }
                        player.prepareToPlay()
                        player.delegate = self
                        player.volume = 10.0
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
        }
    }
    
    @objc func updateProgess()
    {
        let fullRect = self.waveFormImageView.bounds
        let newWidth = Double(fullRect.size.width) * Double(self.second)/10.0/self.player!.duration
        let maskLayer = CAShapeLayer()
        let maskRect = CGRect(x: 0.0, y: 0.0, width: newWidth, height: Double(fullRect.size.height))

        let path = CGPath(rect: maskRect, transform: nil)
        maskLayer.path = path

        self.waveFormImageView.layer.mask = maskLayer
        self.second += 1
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
        }
        else
        {
            print("unsuccessful")
        }
    }
}
