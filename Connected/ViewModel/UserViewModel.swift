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
    
    init(_ uid: String, _ suid: String)
    {
        let realmChat = realm.object(ofType: Chat.self, forPrimaryKey: "\(uid)_\(suid)")
        let chat = Chat(user: User(_id: uid), otherUser: User(_id: suid))
        if realmChat != nil
        {
            ///if is not nil, then load from realm storage
            do
            {
                try realmChat?.messages.forEach({ msg in
                    let result = try self.cacheStorage!.entry(forKey: msg)
                    print("Loading my msg")
                    self.userDataArray.append((UniqueMessage(id: UUID().uuidString, data: result.object), UniqueMessageIdentifier(id: UUID().uuidString, isMe: true, fileName: msg)))
                })
                
                try realmChat?.otherMessages.forEach({ msg in
                    let result = try self.cacheStorage!.entry(forKey: msg)
                    print("Loading other msg")
                    self.userDataArray.append((UniqueMessage(id: UUID().uuidString, data: result.object), UniqueMessageIdentifier(id: UUID().uuidString, isMe: false, fileName: msg)))
                })
            }
            catch
            {
                print("Couldnt load from realm")
            }
            return
        }
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
                        do
                        {
                            try self.realm.write
                            {
                                chat.messages.append(items.name)
                                print("append")
                            }
                        }
                        catch let error as NSError
                        {
                            print(error.localizedDescription)
                        }
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
                                do
                                {
                                    try self.realm.write
                                    {
                                        chat.messages.append(items.name)
                                        print("append")
                                    }
                                }
                                catch let error as NSError
                                {
                                    print(error.localizedDescription)
                                }
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
                        do
                        {
                            try self.realm.write
                            {
                                chat.otherMessages.append(items.name)
                                print("append")
                            }
                        }
                        catch let error as NSError
                        {
                            print(error.localizedDescription)
                        }
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
                                do
                                {
                                    try self.realm.write
                                    {
                                        chat.otherMessages.append(items.name)
                                        print("append")
                                    }
                                }
                                catch let error as NSError
                                {
                                    print(error.localizedDescription)
                                }
                                self.userDataArray.append((UniqueMessage(id: UUID().uuidString, data: data!), UniqueMessageIdentifier(id: UUID().uuidString, isMe: false, fileName: items.name)))
                            }
                        }
                    }
                }
            }
        })
        if realmChat == nil
        {
            do
            {
                try realm.write
                {
                    realm.add(chat, update: .modified)
                }
            }
            catch let error as NSError
            {
                print(error.localizedDescription)
            }
        }
    }
}
