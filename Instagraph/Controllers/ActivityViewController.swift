//
//  ActivityViewController.swift
//  Instagraph
//
//  Created by LI MINCHENG on 18/9/18.
//  Copyright © 2018 Wenzhou Wei. All rights reserved.
//

import Foundation
import UIKit

class ActivityViewController:UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var ActivityTableView: UITableView!
    
    var testData1=["1.jpg", "liked the photo", "1.jpg"]
    var testData2=["1.jpg", "started following you"]

    var page:Int!
    
    var AuthUser: FirebaseUser?
    var FollowerList:[FirebaseUser]=[]
    var ActivitiesData=[BaseActivity]()
    var followuseractivities=[FollowUserActivity]()
    var likephotoactivities=[LikePhotoActivity]()
    var activitiesID=[String]()
    var FollowingList:[String]=[]
    var UserList=[FirebaseUser]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "Billabong", size: 30)!]
        
        ActivityTableView.register(UINib.init(nibName: "ActivityTableViewCell", bundle: nil), forCellReuseIdentifier: "ActivityTableViewCell")
        
        self.getFollowingActivity()
        self.getFollowers()
        //self.getFinalAcitivities()
        page=0
        ActivityTableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        TabIndex.currentSelectedIndex = 3;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if page==0 {
             return ActivitiesData.count
        }
        else {
            return FollowerList.count
        }
       
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=ActivityTableView.dequeueReusableCell(withIdentifier: "ActivityTableViewCell") as! ActivityTableViewCell
        //let str = testData[page][indexPath.row].split(separator: " ")
       
        if(page==0)
        {
            orderActivity()
            if ActivitiesData.count>0 {
                    UserManager.share.getUser(uid: ActivitiesData[indexPath.row].uid, callback: {(activityOwner, error) in
                        UserManager.share.getProfileImage(user: activityOwner!, callback: {(img, error) in
                            if img == nil {
                                cell.AvatorImg.image=nil
                            }else{
                                cell.AvatorImg.image=img
                            }
                        })
                    })
                    
                    if ActivitiesData[indexPath.row].type == "follow" {
                        for j in 0...followuseractivities.count-1 {
                            if followuseractivities[j].id == ActivitiesData[indexPath.row].id {
                                UserManager.share.getUser(uid: ActivitiesData[indexPath.row].uid, callback: {(followingUser,error) in
                                    UserManager.share.getUser(uid: self.followuseractivities[j].uidFollowed, callback: {(followedUser,error) in
                                        cell.ContentTxt.text=(followingUser?.name)!+" started to follow "+(followedUser?.name)!
                                    })
                                })
                                
                                let date=Timestamp.timestampIntToDate(followuseractivities[j].timestamp)
                                cell.TimestampTxt.text=Timestamp.historicDateToReadable(dateFrom: date)
                            }
                        }
                    }
                    else if ActivitiesData[indexPath.row].type == "like" {
                        for j in 0...likephotoactivities.count-1 {
                            if likephotoactivities[j].id == ActivitiesData[indexPath.row].id {
                                UserManager.share.getUser(uid: ActivitiesData[indexPath.row].uid, callback: {(likePhotoUser, error) in
                                    cell.ContentTxt.text=(likePhotoUser?.name)!+" like photos"
                                })
                                let date=Timestamp.timestampIntToDate(likephotoactivities[j].timestamp)
                                 cell.TimestampTxt.text=Timestamp.historicDateToReadable(dateFrom: date)
                                FeedManager.share.getSpecificFeed(feedId: likephotoactivities[j].feedID, callback: {(feed, error) in
                                    FeedManager.share.getFeedImage(feed: feed, callback: {(img, error) in
                                         cell.PhotoImg.image=img
                                    })
                                })
                            }
                        }
                    }
                
                    }

            else{
                cell.AvatorImg.image=nil
                cell.ContentTxt.text="No Activities."
                cell.PhotoImg.image=nil
                cell.TimestampTxt.text=nil
            }
        }
        else{
            if FollowerList.count>0 {
                UserManager.share.getUser(uid: FollowerList[indexPath.row].uid, callback: {(activityOwner, error) in
                    UserManager.share.getProfileImage(user: activityOwner!, callback: {(img, error) in
                        if img == nil {
                            cell.AvatorImg.image=nil
                        }else{
                            cell.AvatorImg.image=img
                        }
                    })
                })
                    cell.ContentTxt.text=FollowerList[indexPath.row].name+" started to follow you."
                    cell.PhotoImg.image=nil
                    cell.TimestampTxt.text=nil
            }
            else{
                cell.AvatorImg.image=nil
                cell.ContentTxt.text="No followers."
                cell.PhotoImg.image=nil
                cell.TimestampTxt.text=nil
            }
        }
        return cell
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ActionOnSwitch(_ sender: UISegmentedControl) {
        page=sender.selectedSegmentIndex
        ActivityTableView.reloadData()
    }
    
    func getFollowers()
    {
       UserManager.share.getAuthUser(callback: {(CurUser, error) in
        UserRelationManager.share.getFollowers(followingUID: (CurUser?.uid)!, callback: {(followers,error) in
            if followers.count>0{
                for i in 0...followers.count-1 {
                     UserManager.share.getUser(uid:followers[i], callback: {(followerUser,error) in
                        self.FollowerList.append(followerUser!)
                        if followerUser?.imageURL != nil {
                            UserManager.share.getProfileImage(user: followerUser!, callback: {(img,error) in
                            self.FollowerList[i].image=img
                        })
                        }
                     })
                    }
                }
            })
       })
    }
    func getFollowingActivity(){
        UserManager.share.getAuthUser(callback: {(CurUser, error) in
            UserRelationManager.share.getFollowings(followerUID: (CurUser?.uid)!, callback: {(followings, error) in
                self.FollowingList=followings
                if followings.count>0 {
                for index in 0...followings.count-1 {
                    ActivityManager.share.searchActivities(uid: followings[index], callback: {(activities,error) in
                        if activities.count>0 {
                            for i in 0...activities.count-1{
                                if activities[i].contains(followings[index]){
                                if activities[i].contains("follow") {
                                    ActivityManager.share.getFollowUserActivity(ActivityId: activities[i], callback: {(activity, error ) in
                                        self.ActivitiesData.append(activity)
                                        self.followuseractivities.append(activity)
                                    })
                                }else if activities[i].contains("like"){
                                    ActivityManager.share.getLikePhotoActivity(ActivityId: activities[i], callback: {(activity, error ) in
                                        self.ActivitiesData.append(activity)
                                        self.likephotoactivities.append(activity)
                                    })
                                }
                                }
                            }
                        }

                    })
                }
                }
            })
        })
        
    }

    func orderActivity(){
        if ActivitiesData.count>0{
            for i in 0...ActivitiesData.count-2 {
                for j in 0...ActivitiesData.count-i-2{
                    if ActivitiesData[j].timestamp<ActivitiesData[j+1].timestamp {
                        let temp: BaseActivity?
                        temp = ActivitiesData[j]
                        ActivitiesData[j]=ActivitiesData[j+1]
                        ActivitiesData[j+1]=temp!
                    }
                }
            }
        }
    }
}
