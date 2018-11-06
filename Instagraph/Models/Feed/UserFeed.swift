//
//  UserFeed.swift
//  Instagraph
//
//  Created by Dafu Ai on 18/9/18.
//  Copyright © 2018 Wenzhou Wei. All rights reserved.
//

import Foundation
import MapKit
import Firebase

class UserFeed: AutoTimestamp {
    var id: String
    var uid: String
    var location: Location?
    var imageURL: String
    var text: String
    var likes: [String: UserFeedLike]
    var comments: [String: UserFeedComment]
    var image: UIImage?
    var isCommenting: Bool = false
    var imageLabels: [String]
    
    init(uid: String, location: Location?, imageURL: String, text: String, imageLabels: [String], timestamp: Int?) {
        self.id = uid + String(Timestamp.timestampDateToInt(Date()))
        self.uid = uid
        self.location = location
        self.imageURL = imageURL
        self.text = text
        self.likes = [:]
        self.comments = [:]
        self.imageLabels = imageLabels
        super.init(timestamp: timestamp)
    }
    
    required init(dict: NSDictionary) {
        self.id = dict["id"] as! String
        self.uid = dict["uid"] as! String
        
        if let locDict = dict["location"] as? NSDictionary {
            self.location = Location(dict: locDict)
        } 
        
        self.imageURL = dict["imageURL"] as! String
        self.text = dict["text"] as! String
        
        self.likes = [:]
        if let dictLikes = dict["likes"] as? NSDictionary {
            var likes:[String: UserFeedLike] = [:]
            dictLikes.allValues.forEach({ val in
                let like = UserFeedLike(dict: val as! NSDictionary)
                likes[like.uid] = like
            })
            self.likes = likes
        }
        
        self.comments = [:]
        if let dictComments = dict["comments"] as? NSDictionary {
            var comments:[String: UserFeedComment] = [:]
            dictComments.allValues.forEach({ val in
                let comment = UserFeedComment(dict: val as! NSDictionary)
                comments[comment.id] = comment
            })
            self.comments = comments
        }

        self.imageLabels = []
        if let imageLabels = dict["imageLabels"] as? NSArray {
            self.imageLabels = imageLabels.map({ label in
                return label as! String
            })
        }
        
        super.init(dict: dict)
    }
    
    override func serialize() -> NSMutableDictionary {
        let dict = super.serialize()
        dict.setValue(self.id, forKey: "id")
        dict.setValue(self.uid, forKey: "uid")
        dict.setValue(self.imageURL, forKey: "imageURL")
        dict.setValue(self.text, forKey: "text")
        dict.setValue(self.imageLabels, forKey: "imageLabels")
        
        if location != nil {
            dict.setValue(self.location, forKey: "location")
        }

        return dict
    }
    
    func isLikedByCurrUser() -> Bool {
        return likes.keys.contains(Auth.auth().currentUser!.uid)
    }
    
    func like(callback: @escaping (Error?) -> Void) {
        let currUserUID = Auth.auth().currentUser!.uid
        let like = UserFeedLike(uid: currUserUID, timestamp: nil)
        
        FeedManager.share.getFeedLikesDBRef(feedID: self.id).child(currUserUID).setValue(like.serialize(), withCompletionBlock: { (error, ref) in
            
            guard error == nil else {
                callback(error)
                return
            }
            
            // Also record like feed activity
            let activity = LikePhotoActivity(uid: currUserUID, feedID: self.id)
            ActivityManager.share.getActivitiesDBRef()?.child(activity.id).setValue(activity.serialize(), withCompletionBlock: { (error, ref) in
                guard error == nil else {
                    callback(error)
                    return
                }
                
                self.likes[currUserUID] = like
                callback(nil)
            })
        })
    }
    
    func unlike(callback: @escaping (Error?) -> Void) {
        let currUserUID = Auth.auth().currentUser!.uid

        FeedManager.share.getFeedLikesDBRef(feedID: self.id).child(currUserUID).removeValue(completionBlock: { (error, ref) in
            if error == nil {
                self.likes.removeValue(forKey: currUserUID)
            }
            
            callback(error)
        })
    }
    
    func addComment(text: String, callback: @escaping (Error?) -> Void) {
        let currUserUID = Auth.auth().currentUser!.uid
        let comment = UserFeedComment(uid: currUserUID, text: text, timestamp: nil)
        
        FeedManager.share.getFeedCommentsDBRef(feedID: self.id).child(comment.id).setValue(comment.serialize()) { (error, ref) in
            if error == nil {
                self.comments[comment.id] = comment
            }
            
            callback(error)
        }
    }

    func getDistToCurrUser() -> CLLocationDistance? {
        guard let currLocation = UserLocationManager.share.currentLocation, self.location != nil else {
            return nil
        }
        let feedLocation = CLLocation(latitude: self.location!.latitude, longitude: self.location!.longitude)
        return currLocation.distance(from: feedLocation)
    }
    
    func getReadableDistToCurrUser() -> String {
        let formatter = MKDistanceFormatter()
        formatter.unitStyle = .default
        
        return formatter.string(fromDistance: self.getDistToCurrUser()!)
    }
    
    func getLabelsInSingleString() -> String {
        var str = ""
        self.imageLabels.forEach { (label) in
            str += " #" + label
        }
        return str
    }
}
