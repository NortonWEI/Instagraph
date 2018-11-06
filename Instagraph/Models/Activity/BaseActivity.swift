//
//  Activity.swift
//  Instagraph
//
//  Created by Dafu Ai on 18/9/18.
//  Copyright © 2018 Wenzhou Wei. All rights reserved.
//

import Foundation

// Extend this class to support different types of activities
class BaseActivity: AutoTimestamp {
    var id: String
    var uid: String
    var type: String

    init(uid: String, timestampInt: Int?, type: String) {
        self.id = uid + String(Timestamp.timestampDateToInt(Date())) + type
        self.uid = uid
        self.type = type
        super.init(timestamp: timestampInt)
    }
    
    required init(dict: NSDictionary) {
        self.id = dict["id"] as! String
        self.uid = dict["uid"] as! String
        self.type = dict["type"] as! String
        super.init(dict: dict)
    }
    
    override func serialize() -> NSMutableDictionary {
        let dict = super.serialize()
        dict.setValue(self.id, forKey: "id")
        dict.setValue(self.uid, forKey: "uid")
        dict.setValue(self.type, forKey: "type")
        return dict
    }
}
