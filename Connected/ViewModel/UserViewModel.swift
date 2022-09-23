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
     
    @Published var audioURLArray: [AVURLAsset] = []
    
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
                    print(url!.absoluteString)
                    self.audioURLArray.append(AVURLAsset(url: url!.absoluteURL))
                }
            }
        }
        print("User Viewmodel init")
    }
}
