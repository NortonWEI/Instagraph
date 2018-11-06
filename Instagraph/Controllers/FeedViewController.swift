//
//  FeedViewController.swift
//  Instagraph
//
//  Created by Margareta  Hardiyanti on 10/09/18.
//  Copyright © 2018 Wenzhou Wei. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

struct ActionBool {
    static var isFirstEnterFeedFromShare = false
}

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var feedsSortMethodSegControl: UISegmentedControl!
    
    var feeds: [UserFeed] = []
    var commentUsers: [String: FirebaseUser] = [:]
    var locationManager: CLLocationManager!
    var feedsSortMethod: FeedManager.FeedsSortMethod = .byTime
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "Billabong", size: 30)!]
        
        UserLocationManager.share.initializeService()
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        refreshControl.addTarget(self, action: #selector(self.handleRefresh(refreshControl:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.reloadFeeds()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        TabIndex.currentSelectedIndex = 0;
        
        if ActionBool.isFirstEnterFeedFromShare {
            ActionBool.isFirstEnterFeedFromShare = false
            reloadFeeds()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func feedsSortMethodChanged(_ sender: Any) {
        if feedsSortMethodSegControl.selectedSegmentIndex == 0 {
            self.feedsSortMethod = .byTime
        } else {
            guard UserLocationManager.share.currentLocation != nil else {
                UserLocationManager.share.displayAlert(vc: self)
                feedsSortMethodSegControl.selectedSegmentIndex = 0
                return
            }
            
            self.feedsSortMethod = .byLocation
        }
        // Reload feeds when sorting methods have been changed
        self.reloadFeeds()
    }
    
    func reloadFeeds() {
        activityIndicator.startAnimating()
        self.feeds = []
        self.tableView.reloadData()
        FeedManager.share.getFollowingUsersFeeds(
            sortMethod: self.feedsSortMethod,
            callback: { (feeds, error) in
                self.feeds = feeds
                feeds.forEach({ feed in
                    let user = UserRelationManager.share.followingUsers[feed.uid]!
                    UserManager.share.getProfileImage(user: user, callback: {(image, error) in
                    })

                    FeedManager.share.getFeedImage(feed: feed, callback: { (image, error) in
                        guard image != nil else {
                            return
                        }
        
                        feed.image = image

                        FeedManager.share.labelImage(image: image!, onLabelling: { (labels) in
                            feed.imageLabels = labels
                            self.activityIndicator.stopAnimating()
                            self.refreshControl.endRefreshing()
                            self.tableView.reloadData()
                        })
                    })
                })
            }
        )
    }
    
    func setupTableView() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.layoutMargins = UIEdgeInsets.zero
        self.tableView.separatorInset = UIEdgeInsets.zero
        
        self.tableView.register(UINib(nibName: "PictureCellTableViewCell", bundle: nil), forCellReuseIdentifier: "picturecell")
        self.tableView.register(UINib(nibName: "CommentTableViewCell", bundle: nil), forCellReuseIdentifier: "commentcell")
        self.tableView.register(UINib(nibName: "AddCommentTableViewCell", bundle: nil), forCellReuseIdentifier: "addcommentcell")
        
        self.tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.feeds.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let feed = self.feeds[section]
        let hasAddComment = feed.isCommenting ? 1 : 0
        return feed.comments.keys.count + 2 + hasAddComment
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let feed = self.feeds[indexPath.section]

        if indexPath.row == 0 {
            return 390
        }
        
        if indexPath.row == 1 {
            return 60
        }
        
        if feed.isCommenting && indexPath.row == 2 {
            return 96
        }
        
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let feed = self.feeds[indexPath.section]
        let user = UserRelationManager.share.followingUsers[feed.uid]!
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "picturecell", for: indexPath) as! PictureCellTableViewCell
            cell.setFeed(feed: feed, user: user, tableView: self.tableView)
            cell.avatarSelected = {
                self.openUserVC(uid: user.uid)
            }
            return cell
        }
        else {
            if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "commentcell", for: indexPath) as! CommentTableViewCell
                let feedUser = UserRelationManager.share.followingUsers[feed.uid]!
                
                cell.setComment(name: feedUser.name, content: feed.text)
                cell.avatarSelected = {
                    self.openUserVC(uid: feedUser.uid)
                }
                return cell
            } else if feed.isCommenting && indexPath.row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "addcommentcell", for: indexPath) as! AddCommentTableViewCell
                cell.setFeed(feed: feed, tableView: self.tableView)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "commentcell", for: indexPath) as! CommentTableViewCell
                let commentIndex = indexPath.row - 2 - (feed.isCommenting ? 1 : 0)
                let comment = feed.comments.values.map({ c in return c })[commentIndex]
                var commentUserName = ""
                
                // Check if we have the user object in the temp storage
                if let commentUser = commentUsers[comment.uid] {
                    commentUserName = commentUser.name
                } else {
                    // Check if the user is in the following user first so we dont load again
                    if let followingUser = UserRelationManager.share.followingUsers[comment.uid] {
                        commentUserName = followingUser.name
                        self.commentUsers[comment.uid] = followingUser
                    } else {
                        // If not we get the user on demand
                        UserManager.share.getUser(uid: comment.uid) { (user, error) in
                            // Reload to display the loaded user's name
                            self.commentUsers[comment.uid] = user
                            self.tableView.reloadData()
                        }
                    }
                }
                
                cell.setComment(name: commentUserName, content: comment.text)
                return cell
            }
        }
    }
    
    @objc func handleRefresh(refreshControl: UIRefreshControl) {
        reloadFeeds()
    }
    
    public func openUserVC (uid : String) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        viewController.setupUserUID(uid: uid)
        viewController.isEnterFromSuggestion = true
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    // Not using this for now
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.row == 3 {
//            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "CommentViewController") as! CommentViewController
//           self.navigationController?.pushViewController(viewController, animated: false)
//        }
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
