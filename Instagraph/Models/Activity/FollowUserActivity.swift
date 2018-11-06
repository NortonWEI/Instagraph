//
//  FollowUserActivity.swift
//  Instagraph
//
//  Created by Dafu Ai on 16/9/18.
//  Copyright © 2018 Wenzhou Wei. All rights reserved.
//

import Foundation

class FollowUserActivity: BaseActivity  {
    var uidFollowed: String
    
    init(uid: String, uidFollowed: String) {
        self.uidFollowed = uidFollowed
        super.init(uid: uid, timestampInt: nil, type: "follow")
    }
    
    required init(dict: NSDictionary) {
        self.uidFollowed = dict["uidFollowed"] as! String
        super.init(dict: dict)
    }
    
    override func serialize() -> NSMutableDictionary {
        let dict = super.serialize()
        dict.setValue(self.uidFollowed, forKey: "uidFollowed")
        return dict
    }
}
