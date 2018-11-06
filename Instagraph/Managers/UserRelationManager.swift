//
//  FollowManager.swift
//  Instagraph
//
//  Created by Dafu Ai on 18/9/18.
//  Copyright © 2018 Wenzhou Wei. All rights reserved.
//

import Firebase
import FirebaseDatabase

class UserRelationManager {
    public static let share = UserRelationManager()
    
    // Follows table reference
    private var followsRef: DatabaseReference!
    
    var followingUsers: [String: FirebaseUser]
    var followingUsersIntialized: Bool
    
    private init() {
        followsRef = Database.database().reference().child("follows")
        self.followingUsers = [:]
        self.followingUsersIntialized = false
    }
    
    // DB reference for user's followers
    public func getUserFollowersDBRef(uid: String) -> DatabaseReference? {
        return followsRef.child(uid).child("followers")
    }
    
    // DB reference for user's following
    public func getUserFollowingsDBRef(uid: String) -> DatabaseReference? {
        return followsRef.child(uid).child("followings")
    }
    
    public func clearFollowingsData() {
        self.followingUsers = [:]
        self.followingUsersIntialized = false
    }
    
    // Initialize user followings data and also listen for updates to keep local data up to date
    public func initializeFollowingsData(onComplete: @escaping (Error?) -> Void) {
        let currUserId = Auth.auth().currentUser!.uid
        
        guard !self.followingUsersIntialized, let ref = self.getUserFollowingsDBRef(uid: currUserId) else {
            onFollowingUsersInitialized(error: nil, externalCallback: onComplete)
            return
        }
        
        // Start listening data updates in user follows
        ref.observe(DataEventType.value, with: { (snapshot) in
            guard snapshot.value != nil, let rawUidsDict = snapshot.value as? NSDictionary else {
                self.onFollowingUsersInitialized(error: nil, externalCallback: onComplete)
                return
            }
            
            var newUIDs = rawUidsDict.allKeys.map({ rawUID in return rawUID as! String })
            // Also append current user to the ids
            newUIDs.append(currUserId)
            let currUIDs = self.followingUsers.keys
            
            // Check for users not following anymore
            for currUID in currUIDs {
                if !newUIDs.contains(currUID) {
                    // If not following anymore, remove
                    self.followingUsers.removeValue(forKey: currUID)
                }
            }
            
            // Get all users first
            UserManager.share.getUsersDBRef().observeSingleEvent(of: .value, with: { (snapshot) in
                let allUsersDict = snapshot.value as! NSDictionary
                
                // Check for new following users
                for newUID in newUIDs {
                    if !currUIDs.contains(newUID) {
                        // If start following new user, add
                        let userDict = allUsersDict[newUID] as! NSDictionary
                        self.followingUsers[newUID] = FirebaseUser(dict: userDict, uid: newUID)
                    }
                }
                self.onFollowingUsersInitialized(error: nil, externalCallback: onComplete)
            }, withCancel: { (error) in
                self.onFollowingUsersInitialized(error: error, externalCallback: onComplete)
            })
        })
    }
    
    public func onFollowingUsersInitialized(error: Error?, externalCallback: (Error?) -> Void) {
        self.followingUsersIntialized = true
        externalCallback(error)
    }
    
    public func followUser(uidToFollow: String, callback: @escaping (Error?) -> Void) {
        // Should have current user
        guard let currAuthUserRaw = Auth.auth().currentUser else {
            return
        }
        
        let currUserUID = currAuthUserRaw.uid
        
        // Update followings
        self.getUserFollowingsDBRef(uid: currUserUID)?.child(uidToFollow).setValue(uidToFollow, withCompletionBlock: { (error, ref) in
            guard error == nil else {
                callback(error)
                return
            }
            
            // Update followers for data retrieval convinience when loading followers
            self.getUserFollowersDBRef(uid: uidToFollow)?.child(currUserUID).setValue(currUserUID, withCompletionBlock: { (error, ref) in
                
                guard error == nil else {
                    callback(error)
                    return
                }
                
                // Add activity history
                let followUserActivity = FollowUserActivity(uid: currUserUID, uidFollowed: uidToFollow)
                ActivityManager.share.getActivitiesDBRef()?.child(followUserActivity.id).setValue((followUserActivity.serialize()), withCompletionBlock: { (error, ref) in
                    callback(error)
                })
            })
        })
    }
    
    public func unfollowUser(uidToUnfollow: String, callback: @escaping (Error?) -> Void) {
        // Should have current user
        guard let currAuthUserRaw = Auth.auth().currentUser else {
            return
        }
        
        let currUserUID = currAuthUserRaw.uid
        
        // Remove uidToUnfollow from followings list
        self.getUserFollowingsDBRef(uid: currUserUID)!.child(uidToUnfollow).removeValue(completionBlock: { (error, ref) in
            guard error == nil else {
                callback(error)
                return
            }
            
            // Remove current user uid from follower list of uidToUnfollow
            self.getUserFollowersDBRef(uid: uidToUnfollow)!.child(currUserUID).removeValue(completionBlock: { (error, ref) in
                callback(error)
            })
        })
    }
    
    // Get array of uids in String that user of uidToCheck follows
    public func getFollowings(followerUID: String, callback: @escaping ([String], Error?) -> Void) {
        if let followingsRef = self.getUserFollowingsDBRef(uid: followerUID) {
            // Get users followed by the current user
            
            followingsRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard snapshot.value != nil else {
                    callback([], nil)
                    return
                }
                
                if let rawUidsDict = snapshot.value as? NSDictionary {
                    let uids = rawUidsDict.allKeys.map({ rawUID in return rawUID as! String })
                    callback(uids, nil)
                } else {
                    callback([], nil)
                }
            }, withCancel: { error in
                callback([], error)
            })
        }
    }
    
    public func getFollowers(followingUID: String, callback: @escaping ([String], Error?) -> Void) {
        if let followersRef = self.getUserFollowersDBRef(uid: followingUID) {
            // Get users followed by the current user
            followersRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard snapshot.value != nil else {
                    callback([], nil)
                    return
                }
                
                if let rawUidsDict = snapshot.value as? NSDictionary {
                    let uids = rawUidsDict.allKeys.map({ rawUID in return rawUID as! String })
                    callback(uids, nil)
                } else {
                    callback([], nil)
                }
            }, withCancel: { error in
                callback([], error)
            })
        }
    }
}
