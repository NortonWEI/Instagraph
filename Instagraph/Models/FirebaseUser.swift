//
//  User.swift
//  Instagraph
//
//  Created by Dafu Ai on 13/9/18.
//  Copyright © 2018 Wenzhou Wei. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class FirebaseUser {
    var uid: String
    var email: String
    var name: String
    var imageURL: String?
    var image: UIImage?
    var isFollowing: Bool
    var labels: [String]
    
    init(uid: String, email: String, name: String, imageURL: String?, labels: [String], isFollowing: Bool = false) {
        self.uid = uid
        self.email = email
        self.name = name
        self.imageURL = imageURL
        self.isFollowing = isFollowing
        self.labels = labels
    }
    
    convenience init(dict: NSDictionary, uid: String) {
        let userLabels = dict["labels"] as? NSArray ?? []
        
        self.init(
            uid: uid,
            email: dict["email"] as? String ?? "",
            name: dict["name"] as? String ?? "",
            imageURL: dict["imageURL"] as? String ?? nil,
            labels: userLabels.map({ label in return label as! String })
        )
    }
    
    // Construct a user from data dictionary (retrieved from database)
    convenience init(snapshot: DataSnapshot) {
        let uid = snapshot.key
        let userDict = snapshot.value as! NSDictionary
        
        self.init(dict: userDict, uid: uid)
    }
    
    // Construct a user from data dictionary (retrieved from database) and check the following status
    convenience init(snapshot: DataSnapshot, currUserUID: String) {
        let uid = snapshot.key
        let userDict = snapshot.value as! NSDictionary
        let userLabels = userDict["labels"] as? NSArray ?? []

        // For the current user, set isFollowing to true
        let isFollowing = uid == Auth.auth().currentUser?.uid ? true : UserRelationManager.share.followingUsers.keys.contains(uid)

        self.init(
            uid: uid,
            email: userDict["email"] as? String ?? "",
            name: userDict["name"] as? String ?? "",
            imageURL: userDict["imageURL"] as? String ?? nil,
            labels: userLabels.map({ label in return label as! String }),
            isFollowing: isFollowing
        )
    }
}
