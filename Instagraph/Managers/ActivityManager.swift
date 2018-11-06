//
//  ActivityManager.swift
//  Instagraph
//
//  Created by Dafu Ai on 18/9/18.
//  Copyright © 2018 Wenzhou Wei. All rights reserved.
//

import Firebase
import FirebaseDatabase

class ActivityManager {
    public static let share = ActivityManager()
    
    // Activities table reference
    private var activitiesRef: DatabaseReference!
    
    private init() {
        activitiesRef = Database.database().reference().child("activities")
    }
    
    // DB reference for user's activities
    public func getActivitiesDBRef() -> DatabaseReference? {
        return activitiesRef
    }
    
    public func searchActivities(uid: String, callback: @escaping ([String], Error?) -> Void) {
       
        var activitiesID=[String]()

        let query = activitiesRef
            .queryOrdered(byChild: "timestamp")

       query.observeSingleEvent(of: .value, with: { (snapshot) in
            guard snapshot.value != nil else {
                callback([],nil)
                return
            }
            if let rawActivitiesDic = snapshot.value as? NSDictionary{
                activitiesID = rawActivitiesDic.allKeys.map({ rawActivity in return rawActivity as! String})
            }

            callback(activitiesID, nil)
        }, withCancel: { (error) in
            callback([], error)
        })


    }
    
    public func getFollowUserActivity(ActivityId: String, callback: @escaping (FollowUserActivity, Error?) -> Void)
    {
        let idRef=self.activitiesRef.child(ActivityId)
        idRef.observeSingleEvent(of: .value, with: {(snapshot) in
            
            if let value = snapshot.value as? NSDictionary{
                let activity = FollowUserActivity(dict: value)
                callback(activity,nil)
            }
        })
        
    }
    
    public func getLikePhotoActivity(ActivityId: String, callback: @escaping (LikePhotoActivity, Error?) -> Void)
    {
        let idRef=self.activitiesRef.child(ActivityId)
        idRef.observeSingleEvent(of: .value, with: {(snapshot) in
            
            if let value = snapshot.value as? NSDictionary{
                let activity = LikePhotoActivity(dict: value)
                callback(activity,nil)
            }
        })
        
    }
}
