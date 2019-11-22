//
//  PlayerRecord.swift
//  Mind Master
//
//  Created by Jia Rui Shan on 2019/11/8.
//  Copyright © 2019 Calpha Dev. All rights reserved.
//

import Foundation
import SwiftyJSON

class PlayerRecord: NSObject {
    
    static var current = PlayerRecord()
    
    // Reaction time
    var reaction: Double? { didSet { save() } }
    
    // Memory challenge
    var memoryMaxLength: Int? { didSet { save() } }
    var memoryItemCount = 8 { didSet { save() } }
    var delayPerItem = 1.0 { didSet { save() } }
    
    /// The segment index of the memory test type.
    var memoryTestType = 0 { didSet { save() } }
    
    override init() {
        reaction = nil
        memoryMaxLength = nil
    }
    
    init(data: JSON) {
        let dictionary = data.dictionaryValue
        
        reaction = dictionary["reaction"]?.double
        memoryMaxLength = dictionary["memoryMaxLength"]?.int
    }
    
    var encodedJSON: JSON {
        var json = JSON()
        json.dictionaryObject?["reaction"] = reaction
        json.dictionaryObject?["memoryMaxLength"] = memoryMaxLength
        json.dictionaryObject?["memoryItemCount"] = memoryItemCount
        json.dictionaryObject?["memoryDelay"] = delayPerItem
        json.dictionaryObject?["memoryTestType"] = memoryTestType
        
        return json
    }
    
    
    /// Recover any data from the cache.
    static func read() {
        if let data = NSKeyedUnarchiver.unarchiveObject(withFile: SAVE_PATH.path) as? Data, let decrypted = NSData(data: data).aes256Decrypt(withKey: AES_KEY), let json = try? JSON(data: decrypted) {
            PlayerRecord.current = PlayerRecord(data: json)
        }
    }
    
    /// Write to cache.
    func save() {
        
        if PlayerRecord.current != self { return }
        
        let encrypted = NSData(data: try! encodedJSON.rawData()).aes256Encrypt(withKey: AES_KEY)!
        NSKeyedArchiver.archiveRootObject(encrypted, toFile: SAVE_PATH.path)
    }
}