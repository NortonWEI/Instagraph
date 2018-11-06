//
//  FeedComment.swift
//  Instagraph
//
//  Created by Dafu Ai on 18/9/18.
//  Copyright © 2018 Wenzhou Wei. All rights reserved.
//

import Foundation

class UserFeedComment: AutoTimestamp {
    var id: String
    var uid: String
    var text: String
    
    init(uid: String, text: String, timestamp: Int?) {
        self.uid = uid
        self.text = text
        self.id = uid + String(Timestamp.timestampDateToInt(Date()))
        super.init(timestamp: timestamp)
    }
    
    required init(dict: NSDictionary) {
        self.id = dict["id"] as! String
        self.uid = dict["uid"] as! String
        self.text = dict["text"] as! String
        super.init(dict: dict)
    }
    
    override func serialize() -> NSMutableDictionary {
        let dict = super.serialize()
        dict.setValue(self.id, forKey: "id")
        dict.setValue(self.uid, forKey: "uid")
        dict.setValue(self.text, forKey: "text")
        return dict
    }
}
