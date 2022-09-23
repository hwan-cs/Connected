//
//  UserViewModel.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/09/21.
//

import Foundation
import Combine
import FirebaseStorage
import AudioToolbox
import DSWaveformImage
import AVFoundation

class UserViewModel: ObservableObject
{
    let storage = Storage.storage()
    
    var userName: String?
    
    @Published var audioURLArray: [URL] = []
    
    var audioWaveImageArray: [UIImage] = []
    
    let waveformImageDrawer = WaveformImageDrawer()
    
    init()
    {
        let storageRef = self.storage.reference()
        let audioRef = storageRef.child("Audios")
        for i in 1...5
        {
            var audios = storageRef.child("Audios/cwv_\(i).m4a")
            audios.downloadURL { url, error in
                if let error = error
                {
                    print(error.localizedDescription)
                }
                else
                {
                    let task = URLSession.shared.downloadTask(with: url!)
                    { downloadedURL, urlResponse, error in
                        guard let downloadedURL = downloadedURL else { return }
                        Task.init
                        {
                            let cachesFolderURL = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                            let audioFileURL = cachesFolderURL!.appendingPathComponent("localAudio.m4a")
                            try? FileManager.default.copyItem(at: downloadedURL, to: audioFileURL)
                            print("huhuhuhu",audioFileURL)
                            let image = try! await self.waveformImageDrawer.waveformImage(fromAudioAt: audioFileURL, with: .init(
                                size: UIScreen.main.bounds.size,
                                backgroundColor: .clear,
                                style: .gradient([.black, .gray]),
                                  position: .middle))
                            self.audioWaveImageArray.append(image)
                            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                            self.audioURLArray.append(audioFileURL)
                        }
                    }
                    task.resume()
                }
            }
        }
        print("User Viewmodel init")
    }
}
