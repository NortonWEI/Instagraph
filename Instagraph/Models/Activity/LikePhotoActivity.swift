//
//  LikePhotoActivity.swift
//  Instagraph
//
//  Created by Dafu Ai on 18/9/18.
//  Copyright © 2018 Wenzhou Wei. All rights reserved.
//

import Foundation

class LikePhotoActivity: BaseActivity {
    var feedID: String
    
    init(uid: String, feedID: String) {
        self.feedID = feedID
        super.init(uid: uid, timestampInt: nil, type: "like")
    }
    
    required init(dict: NSDictionary) {
        self.feedID = dict["feedID"] as! String
        super.init(dict: dict)
    }
    
    override func serialize() -> NSMutableDictionary {
        let dict = super.serialize()
        dict.setValue(self.feedID, forKey: "feedID")
        return dict
    }
}
