//
//  UserService.swift
//  Instagraph
//
//  Created by Dafu Ai on 13/9/18.
//  Copyright © 2018 Wenzhou Wei. All rights reserved.
//

import Firebase
import FirebaseDatabase
import FirebaseStorage
import MapKit

class UserManager {
    public static let share = UserManager()
    
    // User table reference
    private var usersRef: DatabaseReference!

    private var handle: AuthStateDidChangeListenerHandle?
    // Note the difference between currAuthUserRaw used in member functions and currAuthUser
    var currAuthUser: FirebaseUser?
    var currAuthError: Error?
    
    private init() {
        self.usersRef = Database.database().reference().child("users")
    }
    
    public func getUsersDBRef() -> DatabaseReference {
        return usersRef
    }

    public func signIn(with email: String, password: String, callback: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            self.cacheUser(user: user?.user)
            callback(error)
        }
    }
    
    public func signOut() {
        do {
            try Auth.auth().signOut()
            self.removeUser()
            UserRelationManager.share.clearFollowingsData() // Clear temp data in case login again
        } catch _ {
            // Not logged in
        }
    }
    
    public func register(email: String, name: String, password: String, callback: @escaping (Error?) -> Void) {
        // Create new user
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            // Check resgitration result
            guard let user = authResult?.user else {
                callback(error)
                return
            }
            
            var ref: DatabaseReference!
            ref = Database.database().reference()
            
            // Create user record in realtime db and add user detailsdafu information
            ref.child("users").child(user.uid).setValue([
                "name": name,
                "email": email,
            ]) {
                (error:Error?, ref:DatabaseReference) in
                callback(error)
            }
        }
    }
    
    public func getAuthUser(callback: @escaping (FirebaseUser?, Error?) -> Void) {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            guard user != nil else {
                callback(nil, nil)
                return;
            }
            
            // Get user info and notify listener
            self.getUser(uid: user!.uid, callback: { (user, error) in
                self.currAuthUser = user
                self.currAuthError = error
                callback(user, error)
            })
        }
    }
    
    public func getUser(uid: String, callback: @escaping (FirebaseUser?, Error?) -> Void)  {
        usersRef.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            // User not found
            guard snapshot.value != nil else {
                callback(nil, nil)
                return
            }
            
            // Bug fix for invalid snapshot value
            let value = snapshot.value as? NSDictionary
            guard value != nil else {
                callback(nil, nil)
                return
            }
            
            let user: FirebaseUser
            
            // Create User object
            if let currUser = Auth.auth().currentUser {
                user = FirebaseUser(snapshot: snapshot, currUserUID: currUser.uid)
            } else {
                user = FirebaseUser(snapshot: snapshot)
            }
        
            // Notify listener
            callback(user, nil)
        }) { (error) in
            callback(nil, error)
        }
    }
    
    public func getProfileImage(user: FirebaseUser, callback: @escaping (UIImage?, Error?) -> Void) {
        guard user.imageURL != nil else {
            // If no image, give default photo
            callback(UIImage(named: "user"), nil)
            return
        }
        
        if UserRelationManager.share.followingUsers.keys.contains(user.uid) {
            if user.image != nil {
                callback(user.image!, nil)
                return
            }
        }
        
        let reference = Storage.storage().reference(forURL: user.imageURL!)
        
        // Download in memory with a maximum allowed size of 10MB 
        reference.getData(maxSize: 10 * 1024 * 1024, completion: { data, error in
            if let error = error {
                callback(nil, error)
            } else {
                let image = UIImage(data: data!)
                // Save image data to local copy
                if UserRelationManager.share.followingUsers.keys.contains(user.uid) {
                    user.image = image
                    UserRelationManager.share.followingUsers[user.uid] = user
                }
                callback(image, nil)
            }
        })
    }
    
    public func updateProfileImage(uid: String, image: UIImage, callback: @escaping (URL?, Error?) -> Void) {
        let storage = Storage.storage()
        var data = Data()
        data = UIImageJPEGRepresentation(image, 0.2)! // Also compress image
        let storageRef = storage.reference()
        let imageRef = storageRef.child("images/\(uid).jpeg")
        
        // Upload image
        _ = imageRef.putData(data, metadata: nil, completion: { (metaData, error) in
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
                
                // Store image url into users table
                self.usersRef.child(uid).child("imageURL").setValue(url!.absoluteString)
                {
                    (error:Error?, ref:DatabaseReference) in
                    guard error == nil else {
                        callback(nil, error)
                        return
                    }
                    
                    callback(url, nil)
                }
            })
        })
    }
    
    public func searchUsers(name: String, callback: @escaping ([FirebaseUser], Error?) -> Void) {
        // Should have current user
        guard let currAuthUserRaw = Auth.auth().currentUser else {
            return
        }
        
        // Prepare search query
        let searchString = name
        let searchQuery = usersRef
            .queryStarting(atValue: searchString, childKey: "name")
            .queryEnding(atValue: searchString + "\u{f8ff}", childKey: "name")
            .queryOrdered(byChild: "name")
        
        searchQuery.observeSingleEvent(of: .value, with: { (snapshot) in
            var users: [FirebaseUser] = []
            
            // Make user dictionary from data snapshot
            for child in snapshot.children {
                let childSnapshot = child as! DataSnapshot
                let user = FirebaseUser(snapshot: childSnapshot, currUserUID: currAuthUserRaw.uid)
                users.append(user)
            }
            
            callback(users, nil)
        }, withCancel: { (error) in
            callback([], error)
        })
    }
    
    // Start CONTINOUS updates of user suggestions
    // Algorithms we have:
    // 1. (Basic): Using existing following connections to find other users that have not been followed
    //             However if this user does not follow anyone, will suggest random users.
    // 2. (Intermediate): Search for nearby users, by this we mean the users who have posted feeds nearby
    // 3. (Advanced): Compare user labels generated from machine learning image recognition (on user feed images)
    public func startUserSuggestions(onNewSuggestionFound: @escaping (FirebaseUser, String) -> Void, shouldStopSearching: @escaping () -> Bool) {
        // Should have current user
        guard let currAuthUserRaw = Auth.auth().currentUser else {
            return
        }
        
        // Firstly retrieve the uids that the current user follow
        let uids = UserRelationManager.share.followingUsers.keys
        
        // Check if user does not follow anyone, then just recommend random users
        guard uids.count != 0 else {
            // Up to 10 suggestions
            self.usersRef.queryLimited(toFirst: 10).observeSingleEvent(of: .value, with: { (snapshot) in
                // Make user dictionary from data snapshot
                for child in snapshot.children {
                    let childSnapshot = child as! DataSnapshot
                    let user = FirebaseUser(snapshot: childSnapshot, currUserUID: currAuthUserRaw.uid)
                    
                    if user.uid != currAuthUserRaw.uid {
                        // Notify new suggestion listener
                        onNewSuggestionFound(user, "Random suggestion")
                    }
                }
            })
            return
        }
         
        for uid in uids {
            // 1. Then for each uid that the current user follow, find the uids that this current uid follows
            UserRelationManager.share.getFollowings(followerUID: uid, callback: { (_uids, error) in
                // Check if the caller want to stop searching
                guard shouldStopSearching() != true else {
                    return
                }
                
                // Filter out users that are already followed by the current user
                let uidsNotYetFollowed = _uids.filter({ _uid in
                    return !uids.contains(_uid)
                })
                
                // For each uid to suggest, get the Firebase user object
                for uidToSuggest in uidsNotYetFollowed {
                    // Check if the caller want to stop searching
                    guard shouldStopSearching() != true else {
                        return
                    }
                    
                    self.getUser(uid: uidToSuggest, callback: { (user, error) in
                        if user != nil {
                            // Notify listener of a new suggestion result
                            onNewSuggestionFound(user!, "Followed by " + UserRelationManager.share.followingUsers[uid]!.name)
                        }
                    })
                }
            })
        }
        
        // 2. Search for users who have posted feeds nearby (only if when location of current user is known)
        if UserLocationManager.share.currentLocation != nil {
            FeedManager.share.getFeedDBRef().observeSingleEvent(of: .value) { (snapshot) in
                let dataDict = snapshot.value as! NSDictionary
                let feeds = dataDict.allValues.map({ rawFeed in return UserFeed(dict: rawFeed as! NSDictionary) })
                for feed in feeds {
                    // 1) Keep only feeds of users has not been followed by the current user
                    // 2) Dont check feeds that do not contain location information
                    if uids.contains(feed.uid) || feed.location == nil {
                        continue
                    }
                    
                    // Compare distance between feed location and curr user location
                    let currLocation = UserLocationManager.share.currentLocation!
                    let feedLocation = CLLocation(latitude: feed.location!.latitude, longitude: feed.location!.longitude)
                    let distance = currLocation.distance(from: feedLocation)
                    
                    // Within 100km
                    if distance < 100000 {
                        UserManager.share.getUser(uid: feed.uid, callback: { (user, _) in
                            onNewSuggestionFound(user!, "Nearby (" + feed.getReadableDistToCurrUser() + ")")
                        })
                    }
                }
            }
        }
        
        // 3. User recommendation by user labels which were previously analysed by Firebase Machine Learning on the feed images that the user uploaded
        self.usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            // Make user dictionary from data snapshot
            for child in snapshot.children {
                let childSnapshot = child as! DataSnapshot
                let user = FirebaseUser(snapshot: childSnapshot, currUserUID: currAuthUserRaw.uid)
                
                if user.uid != currAuthUserRaw.uid {
                    var similarUser = false
                    let currentUserLabels = UserRelationManager.share.followingUsers[currAuthUserRaw.uid]!.labels
                    
                    for label in user.labels {
                        if currentUserLabels.contains(label) {
                            similarUser = true
                            break
                        }
                    }
                    
                    if similarUser {
                        // Notify new suggestion listener
                        onNewSuggestionFound(user, "Posted similar feed images (Powerd by ML)")
                    }
                }
            }
        })
        return
    }
    
    public func cacheUser(user : User?) {
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: user as Any)
        UserDefaults.standard.set(encodedData, forKey: "loginUser")
    }
    
    public func cachedUser() -> User? {
        let encodedData = UserDefaults.standard.object(forKey: "loginUser")
        if encodedData != nil {
            return NSKeyedUnarchiver.unarchiveObject(with: encodedData as! Data) as? User
        }
        return nil
    }
    
    public func removeUser() {
        UserDefaults.standard.removeObject(forKey: "loginUser")
    }
    
    public func getFollowers(uid : String? = nil) -> DatabaseReference {
        var id = Auth.auth().currentUser?.uid
        if let userUID = uid {
            id = userUID
        }
        let useref = UserRelationManager.share.getUserFollowersDBRef(uid: id!)
        return useref!
    }
    
    public func getFollowings(uid : String? = nil) -> DatabaseReference {
        var id = Auth.auth().currentUser?.uid
        if let userUID = uid {
            id = userUID
        }
        let useref = UserRelationManager.share.getUserFollowingsDBRef(uid: id!)
        return useref!
    }

    public func updateUserLabel(uid: String, labels: [String], onLabelSaved: @escaping (Error?) -> Void) {
        getUser(uid: uid, callback: {(user, error) in
            if let user = user {
                var userLabels = user.labels
                userLabels += labels
                userLabels = Array(Set(userLabels)) //filter out duplicate
                
                self.usersRef.child(uid).child("labels").setValue(userLabels) {
                    (error:Error?, ref:DatabaseReference) in
                    guard error == nil else {
                        onLabelSaved(error)
                        return
                    }
                    
                    onLabelSaved(nil)
                }
            }
        })
    }
}
