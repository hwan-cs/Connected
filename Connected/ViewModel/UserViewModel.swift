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
import RealmSwift

class UserViewModel: ObservableObject
{
    let storage = Storage.storage()
    
    var userName: String?
    
    @Published var userDataArray = [(UniqueMessage,UniqueMessageIdentifier)]()
    
    let waveformImageDrawer = WaveformImageDrawer()
    
    let diskConfig = DiskConfig(name: "DiskCache")
    
    let memoryConfig = MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10)
    
    lazy var cacheStorage: Cache.Storage<String, Data>? =
    {
        return try? Cache.Storage(diskConfig: diskConfig, memoryConfig: memoryConfig, transformer: TransformerFactory.forData())
    }()
    
    var dataSource: UITableViewDiffableDataSource<UniqueMessage.ID, UniqueMessageIdentifier.ID>!
    
    let realm = try! Realm()
    
    @ObservedResults(Chat.self) var chat
    
    init(_ uid: String, _ suid: String)
    {
        let initChat = try! Chat(user: User(_id: ObjectId(string: uid)), otherUser: User(_id: ObjectId(string: suid)))
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
                        initChat.messages.append(items.name)
                        self.userDataArray.append((UniqueMessage(id: UUID().uuidString, data: result.object), UniqueMessageIdentifier(id: UUID().uuidString, isMe: true, fileName: items.name)))
                    }
                    catch
                    {
                        items.getData(maxSize: 5*1024*1024)
                        { data, dError in
                            if let dError = dError
                            {
                                print(dError.localizedDescription)
                            }
                            else
                            {
                                self.cacheStorage?.async.setObject(data!, forKey: items.name, completion: {_ in})
                                initChat.messages.append(items.name)
                                self.userDataArray.append((UniqueMessage(id: UUID().uuidString, data: data!), UniqueMessageIdentifier(id: UUID().uuidString, isMe: true, fileName: items.name)))
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
                        initChat.messages.append(items.name)
                        self.userDataArray.append((UniqueMessage(id: UUID().uuidString, data: result.object), UniqueMessageIdentifier(id: UUID().uuidString, isMe: false, fileName: items.name)))
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
                                initChat.messages.append(items.name)
                                self.userDataArray.append((UniqueMessage(id: UUID().uuidString, data: data!), UniqueMessageIdentifier(id: UUID().uuidString, isMe: false, fileName: items.name)))
                            }
                        }
                    }
                }
            }
        })
    }
}
