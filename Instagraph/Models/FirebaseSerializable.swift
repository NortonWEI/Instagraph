//
//  Serializable.swift
//  Instagraph
//
//  Created by Dafu Ai on 18/9/18.
//  Copyright © 2018 Wenzhou Wei. All rights reserved.
//

import Foundation

protocol FirebaseSerializable {
    // Unserialize from dict data retrived from Firebase database
    init(dict: NSDictionary)
    // Serialize to dict data which can be stored in Firebase datatabase
    func serialize() -> NSMutableDictionary
}
