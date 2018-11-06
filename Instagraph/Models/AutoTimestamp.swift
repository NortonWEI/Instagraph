//
//  AutoTimestamp.swift
//  Instagraph
//
//  Created by Dafu Ai on 18/9/18.
//  Copyright © 2018 Wenzhou Wei. All rights reserved.
//

import Foundation

// Extend class if the model needs to have timestamp feature
class AutoTimestamp: FirebaseSerializable {
    var timestamp: Int

    init(timestamp: Int?) {
        self.timestamp = timestamp == nil ? Timestamp.timestampDateToInt(Date()) : timestamp!
    }
    
    required init(dict: NSDictionary) {
        self.timestamp = dict["timestamp"] as! Int
    }
    
    func serialize() -> NSMutableDictionary {
        let dict = NSMutableDictionary()
        dict.setValue(timestamp, forKey: "timestamp")
        return dict
    }
    
    func getDate() -> Date {
        return Timestamp.timestampIntToDate(self.timestamp)
    }
}
