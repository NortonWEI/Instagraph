//
//  UserFeedLike.swift
//  Instagraph
//
//  Created by Dafu Ai on 18/9/18.
//  Copyright © 2018 Wenzhou Wei. All rights reserved.
//

import Foundation

class UserFeedLike: AutoTimestamp {
    var uid: String
    
    init(uid: String, timestamp: Int?) {
        self.uid = uid
        super.init(timestamp: timestamp)
    }
    
    required init(dict: NSDictionary) {
        self.uid = dict["uid"] as! String
        super.init(dict: dict)
    }
    
    override func serialize() -> NSMutableDictionary {
        let dict = super.serialize()
        dict.setValue(self.uid, forKey: "uid")
        return dict
    }
}
