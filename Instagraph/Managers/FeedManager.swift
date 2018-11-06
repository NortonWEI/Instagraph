//
//  FeedManager.swift
//  Instagraph
//
//  Created by Dafu Ai on 18/9/18.
//  Copyright © 2018 Wenzhou Wei. All rights reserved.
//

import Firebase
import FirebaseDatabase
import CoreLocation

class FeedManager {
    public static let share = FeedManager()
    
    // Feed table reference
    private var feedsRef: DatabaseReference!
    
    private lazy var vision = Vision.vision()
    // Adjust label threshold here
    private var labelDetectorOptions = VisionLabelDetectorOptions(confidenceThreshold: 0.5)
    
    private init() {
        self.feedsRef = Database.database().reference().child("feeds")
    }
    
    public func getUserFeedsCount(uid: String? = nil, callback: @escaping (Int, Error?) -> Void) {
        var userUID = Auth.auth().currentUser?.uid
        if let useruid = uid {
            userUID = useruid
        }
        let query = self.feedsRef.queryOrdered(byChild: "uid").queryEqual(toValue: userUID)
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            callback(snapshot.children.allObjects.count, nil)
        }, withCancel: { (error) in
            callback(0, error)
        })
    }
    
    public func getUserFeeds(uid: String? = nil, callback: @escaping ([UserFeed], Error?) -> Void) {
        var userUID = Auth.auth().currentUser?.uid
        if let useruid = uid {
            userUID = useruid
        }
        
        let query = self.feedsRef.queryOrdered(byChild: "uid").queryEqual(toValue: userUID)
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            
            var feeds : [UserFeed] = []
            let snapshots : [DataSnapshot] = snapshot.children.allObjects as! [DataSnapshot]
            for child in snapshots {
                if let dictionary = child.value as? NSDictionary {
                    feeds.append(UserFeed(dict: dictionary))
                }
            }
            
            callback(feeds, nil)
        }, withCancel: { (error) in
            callback([], error)
        })
    }
    
    public func getFeedDBRef() -> DatabaseReference {
        return feedsRef
    }
    
    public func getFeedLikesDBRef(feedID: String) -> DatabaseReference {
        return getFeedDBRef().child(feedID).child("likes")
    }
    
    public func getFeedCommentsDBRef(feedID: String) -> DatabaseReference {
        return getFeedDBRef().child(feedID).child("comments")
    }
    
    enum FeedsSortMethod {
        case byTime, byLocation
    }
    
    // Retrieve all feeds for the following users (including the current user)
    public func getFollowingUsersFeeds(sortMethod: FeedsSortMethod, callback: @escaping ([UserFeed], Error?) -> Void) {        
        let followingUIDs = UserRelationManager.share.followingUsers.keys
        
        feedsRef
            .observeSingleEvent(of: .value, with: { snapshot in
                let dataDict = snapshot.value as? NSDictionary ?? NSDictionary()
                var feeds = dataDict.allValues.map({ rawFeed in return UserFeed(dict: rawFeed as! NSDictionary) })
                // First, keep only feeds of following users
                feeds = feeds.filter({ feed in return followingUIDs.contains(feed.uid) })
                
                if sortMethod == .byTime {
                    // Latest feed comes first
                    feeds.sort(by: { feed1, feed2 in
                        return feed1.timestamp > feed2.timestamp
                    })
                } else if sortMethod == .byLocation {
                    // We need to have curr location available to sort by location
                    let currLocation = UserLocationManager.share.currentLocation!
                    
                    // If we have location data available, resort the feeds by
                    feeds.sort(by: { feed1, feed2 in
                        // Feeds that dont have location data will be pushed to the back
                        if feed1.location == nil || feed2.location == nil{
                            return false
                        }
                        
                        let loc1 = CLLocation(latitude: feed1.location!.latitude, longitude: feed1.location!.longitude)
                        let loc2 = CLLocation(latitude: feed2.location!.latitude, longitude: feed2.location!.longitude)
                        
                        // Compare distance between feed location and curr user location
                        return currLocation.distance(from: loc1) < currLocation.distance(from: loc2)
                    })
                }
                callback(feeds, nil)
            }, withCancel: { error in
                callback([], error)
            })
    }
    
    public func getFeedImage(feed: UserFeed, callback: @escaping (UIImage?, Error?) -> Void) {
        let reference = Storage.storage().reference(forURL: feed.imageURL)
        
        // Download in memory with a maximum allowed size of 10MB
        reference.getData(maxSize: 10 * 1024 * 1024, completion: { data, error in
            if let error = error {
                callback(nil, error)
            } else {
                let image = UIImage(data: data!)
                callback(image, nil)
            }
        })
    }
    
    public func getSpecificFeed(feedId: String, callback: @escaping (UserFeed, Error?) -> Void){
        let idRef=self.feedsRef.child(feedId)
        idRef.observeSingleEvent(of: .value, with: {(snapshot) in
            
            if let value = snapshot.value as? NSDictionary{
                let feed = UserFeed(dict: value)
                callback(feed,nil)
            }
        })
    }
    
    // Start analysing image using Firebase ML and will call onLabelling when analysis is done
    public func labelImage(image: UIImage, onLabelling: @escaping ([String]) -> Void ) -> Void {
        let labelDetector = self.vision.labelDetector(options: labelDetectorOptions)
        // Image should be compressed! otherwise processing maybe very slow
        let image = VisionImage(image: image)
        labelDetector.detect(in: image) { features, error in
            let labels = features?.map({ label in
                return label.label
            })
            onLabelling(labels ?? [])
        }
    }
    
    public func uploadFeedImage(feedId: String, image: UIImage, callback: @escaping (URL?, Error?) -> Void) {
        let storage = Storage.storage()
        var data = Data()
        data = UIImageJPEGRepresentation(image, 0.2)! // Also compress image
        let storageRef = storage.reference()
        let imageRef = storageRef.child("images/\(feedId).jpeg")
        
        // Upload image
        imageRef.putData(data, metadata: nil, completion: { (metaData, error) in
            guard metaData != nil else {
                callback(nil, error)
                return
            }
            
            // Retrieve download url for image
            imageRef.downloadURL(completion: { (url, error) in
                guard error == nil else {
                    callback(nil, error)
                    return
                }
                callback(url, nil)
            })
        })
    }
}
