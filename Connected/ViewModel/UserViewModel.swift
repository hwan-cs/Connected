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
    
    var audioName: [String] = []
    
    @Published var audioArray: [Data] = []
    
    var audioWaveImageArray: [UIImage] = []
    
    let waveformImageDrawer = WaveformImageDrawer()
    
    init(_ uid: String, _ suid: String)
    {
        let storageRef = self.storage.reference()
        let audioRef = storageRef.child("\(uid)/\(suid)/")
        audioRef.listAll(completion:
        { (storageListResult, error) in
            if let error = error
            {
                print(error.localizedDescription)
            }
            else
            {
                for items in storageListResult!.items
                {
                    items.getData(maxSize: 1*1024*1024)
                    { data, errpr in
                        if let error = error
                        {
                            print(error.localizedDescription)
                        }
                        else
                        {
                            print(data!)
                            self.audioName.append(items.name)
                            self.audioArray.append(data!)
                        }
                    }
                }
            }
        })
        print("User Viewmodel init")
    }
}
