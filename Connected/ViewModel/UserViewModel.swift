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
import Cache

class UserViewModel: ObservableObject
{
    let storage = Storage.storage()
    
    var userName: String?
    
    var audioName: [String] = []
    
    @Published var audioArray: [Data] = []
    
    var audioWaveImageArray: [UIImage] = []
    
    let waveformImageDrawer = WaveformImageDrawer()
    
    let diskConfig = DiskConfig(name: "DiskCache")
    
    let memoryConfig = MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10)
    
    lazy var cacheStorage: Cache.Storage<String, Data>? =
    {
        return try? Cache.Storage(diskConfig: diskConfig, memoryConfig: memoryConfig, transformer: TransformerFactory.forData())
    }()
    
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
                    do
                    {
                        let result = try self.cacheStorage!.entry(forKey: items.name)
                        // The video is cached.
                        print("audio cached")
                        self.audioName.append(items.name)
                        self.audioArray.append(result.object)
                    }
                    catch
                    {
                        items.getData(maxSize: 1*1024*1024)
                        { data, dError in
                            if let dError = dError
                            {
                                print(dError.localizedDescription)
                            }
                            else
                            {
                                self.cacheStorage?.async.setObject(data!, forKey: items.name, completion: {_ in})
                                self.audioName.append(items.name)
                                self.audioArray.append(data!)
                            }
                        }
                    }
                }
            }
        })
        print("User Viewmodel init")
    }
}
