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
    
    @Published var userDataArray: [Data:[AnyHashable]] = [:]
    
    let waveformImageDrawer = WaveformImageDrawer()
    
    let diskConfig = DiskConfig(name: "DiskCache")
    
    let memoryConfig = MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10)
    
    lazy var cacheStorage: Cache.Storage<String, Data>? =
    {
        return try? Cache.Storage(diskConfig: diskConfig, memoryConfig: memoryConfig, transformer: TransformerFactory.forData())
    }()
    
    var dataSource: UITableViewDiffableDataSource<Data, [AnyHashable]>!
    
    init(_ uid: String, _ suid: String)
    {
        let storageRef = self.storage.reference()
        let myAudioRef = storageRef.child("\(uid)/\(suid)/")
        myAudioRef.listAll(completion:
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
                        self.userDataArray[result.object] = [true, items.name]
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
                                self.userDataArray[data!] = [true, items.name]
                            }
                        }
                    }
                }
            }
        })
        let yourAudioRef = storageRef.child("\(suid)/\(uid)/")
        yourAudioRef.listAll(completion:
        { (storageListResult, error) in
            if let error = error
            {
                print("error")
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
                        self.userDataArray[result.object] = [false, items.name]
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
                                self.userDataArray[data!] = [false, items.name]
                            }
                        }
                    }
                }
            }
        })
    }
}
