//
//  ProfileViewController.swift
//  Instagraph
//
//  Created by Dafu Ai on 12/9/18.
//  Copyright © 2018 Wenzhou Wei. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController ,  UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    @IBOutlet weak var emailAddressLabel: UILabel!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var followingTitleLabel: UILabel!
    @IBOutlet weak var followerTitleLabel: UILabel!
    @IBOutlet weak var followersValueLabel: UILabel!
    @IBOutlet weak var followingValueLabel: UILabel!
    @IBOutlet weak var postValueLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var logoutButton: TertiaryButton!
    
    var userUID : String?
    
    var user: FirebaseUser?
    var feeds: [UserFeed]?
    
    var isEnterFromSuggestion = false
    
    override func viewWillAppear(_ animated: Bool) {
        // We need to get Firebase user rather than raw user
       self.fetchUserInformation()
    }

    func setupUserUID(uid : String) {
        self.userUID = uid
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "Billabong", size: 30)!]
        
        if isEnterFromSuggestion {
            logoutButton.isHidden = true
        }
        
        self.setupViews()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        TabIndex.currentSelectedIndex = 4;
        
        self.retrieveFollowingsFollowers()
    }
    
    func setupViews() {
        self.emailAddressLabel.font = FontObject.sharedInstance.bodyCopy2
        self.emailAddressLabel.textColor = ColorObject.sharedInstance.darkGray1
        
        self.displayNameLabel.font = FontObject.sharedInstance.bodyCopy1Bold
        self.displayNameLabel.textColor = ColorObject.sharedInstance.purpleMainColor
        
        self.profileImageView.layer.cornerRadius = 50
        self.profileImageView.clipsToBounds = true;
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.profilePictureTapped))
        self.profileImageView.addGestureRecognizer(tapGesture)
        self.profileImageView.isUserInteractionEnabled = true
        
        self.followerTitleLabel.font = FontObject.sharedInstance.bodyCopy2Bold
        self.followerTitleLabel.textColor = ColorObject.sharedInstance.darkGray1
        self.followerTitleLabel.text = "Followers"
        
        self.followingTitleLabel.font = FontObject.sharedInstance.bodyCopy2Bold
        self.followingTitleLabel.textColor = ColorObject.sharedInstance.darkGray1
        self.followingTitleLabel.text = "Followings"
        
        self.postTitleLabel.font = FontObject.sharedInstance.bodyCopy2Bold
        self.postTitleLabel.textColor = ColorObject.sharedInstance.darkGray1
        self.postTitleLabel.text = "Posts"
        
        self.followersValueLabel.font = FontObject.sharedInstance.bodyCopy2Bold
        self.followersValueLabel.textColor = ColorObject.sharedInstance.darkGray1
        self.followingValueLabel.font = FontObject.sharedInstance.bodyCopy2Bold
        self.followingValueLabel.textColor = ColorObject.sharedInstance.darkGray1

        
        self.postValueLabel.font = FontObject.sharedInstance.bodyCopy2Bold
        self.postValueLabel.textColor = ColorObject.sharedInstance.darkGray1

        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "imageCollectionViewCell")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayUserProfile() {
        self.emailAddressLabel.text = user?.email
        self.displayNameLabel.text = user?.name
        
        if user?.imageURL != nil {
            UserManager.share.getProfileImage(user: self.user!, callback: { (image, error) in
                if error != nil {
                    self.displayAlert(title: "Failed to load profile image", message: error!.localizedDescription)
                } else {
                    self.profileImageView.image = image
                }
            })
        } else {
            // Only display button if image is not set
        }
    }
    
    func fetchUserInformation() {
        if let userUID = self.userUID{
            UserManager.share.getUser(uid: userUID) { (user, error) in
                self.user = user
                self.displayUserProfile()
            }
        }
        else {
            UserManager.share.getAuthUser(callback: { (user, error) in
                if user != nil {
                    self.user = user
                    self.displayUserProfile()
                }
            })
        }
    }
    
    @IBAction func logoutButtonClicked(_ sender: Any) {
        UserManager.share.signOut()
        LoginViewController.enter()
    }
    
    @objc func profilePictureTapped() {
        // User shouldn't be undefined
        guard user != nil else {
            return
        }
        
        ImageHandler.shared.showActionSheet(vc: self)
        ImageHandler.shared.imagePickedBlock = { (image) in
            let spinner = UIViewController.displaySpinner(onView: self.view)
            
            UserManager.share.updateProfileImage(uid: self.user!.uid, image: image, callback: { (url, error) in
                if error != nil {
                    self.displayAlert(title: "Failed to upload profile image", message: error!.localizedDescription)
                } else {
                    self.profileImageView.image = image
                }
                UIViewController.removeSpinner(spinner: spinner)
            })
        }
    }
    
    func displayAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontalPadding  : CGFloat = 15
        let width = (UIScreen.main.bounds.size.width - horizontalPadding)/3
        let height = width
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0,0,0,0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let feeds = self.feeds {
            return feeds.count
        }
        return 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCollectionViewCell", for: indexPath) as! ImageCollectionViewCell
        let feed = self.feeds?[indexPath.row]
        if let url = feed?.imageURL {
            cell.setImageUrl(url: url)
        }
      
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.userUID == nil {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let detailVC = mainStoryboard.instantiateViewController(withIdentifier: "FeedDetailViewController") as! FeedDetailViewController
            
            let feed = self.feeds?[indexPath.row]
            if let url = feed?.imageURL {
                detailVC.setImageUrl(imageUrl: url)
            }
            self.navigationController?.pushViewController(detailVC, animated: false)
        }
    }
    
    func retrieveFollowingsFollowers() {
        
        UserManager.share.getFollowers(uid: self.userUID).queryOrderedByValue().observeSingleEvent(of: .value, with: { (snapshot) in
            let count = snapshot.children.allObjects.count
            self.followersValueLabel.text = String(format: "%d", count)
        })
        
        UserManager.share.getFollowings(uid: self.userUID).queryOrderedByValue().observeSingleEvent(of: .value, with: { (snapshot) in
            let count = snapshot.children.allObjects.count
            self.followingValueLabel.text = String(format: "%d", count)
        })
        
        
        FeedManager.share.getUserFeedsCount(uid: self.userUID, callback: { (count, error) in
                self.postValueLabel.text = String(format: "%d", count)
        })
        
        FeedManager.share.getUserFeeds (uid: self.userUID, callback: { (feeds, error) in
            self.feeds = feeds
            self.collectionView.reloadData()
        })
    }
}
