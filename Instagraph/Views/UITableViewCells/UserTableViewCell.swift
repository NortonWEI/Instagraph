//
//  UserTableViewCell.swift
//  Instagraph
//
//  Created by Margareta  Hardiyanti on 11/09/18.
//  Copyright © 2018 Wenzhou Wei. All rights reserved.
//

import UIKit
import Firebase

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var followButton: TertiaryButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var suggestionSourceLabel: UILabel!
    
    var user: FirebaseUser? = nil
     var avatarSelected : (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.setupViews()
    }
    
    func setupViews() {
        self.avatarImageView.layer.cornerRadius = 18
        self.avatarImageView.clipsToBounds = true
        
        self.nameLabel.textColor = ColorObject.sharedInstance.darkGray1
        self.nameLabel.font = FontObject.sharedInstance.bodyCopy2
        self.selectionStyle = .none
        
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(PictureCellTableViewCell.nameSelected))
        self.nameLabel.isUserInteractionEnabled = true
        self.nameLabel.addGestureRecognizer(tapGesture)
        
        let avatarTapGesture = UITapGestureRecognizer()
        avatarTapGesture.addTarget(self, action: #selector(PictureCellTableViewCell.imageSelected))
        self.avatarImageView.isUserInteractionEnabled = true
        self.avatarImageView.addGestureRecognizer(avatarTapGesture)
    }
    
    func setAvatar(user: FirebaseUser, suggestionSource: String?) {
        self.user = user
        self.avatarImageView.image = user.image
        self.nameLabel.text = self.user!.name
        self.suggestionSourceLabel.text = suggestionSource
        
        showToggleFollowingButton()
    }

    func showToggleFollowingButton() {
        if let rawUser = Auth.auth().currentUser {
            if rawUser.uid == self.user!.uid {
                // Hide follow button for the self user
                self.followButton.isHidden = true
                return
            }
        }
        
        if self.user!.isFollowing {
            self.followButton.setTitle("Unfollow",for: .normal)
        } else {
            self.followButton.setTitle("Follow",for: .normal)
        }
        self.followButton.isHidden = false
    }
    
    @IBAction func toggleFollowButtonClicked(_ sender: Any) {
        let spinner = UIViewController.displaySpinner(onView: self.contentView)

        if self.user!.isFollowing {
            // Revert toggle button first for instant visual effect
            invertToggleFollowingButton()
            UserRelationManager.share.unfollowUser(uidToUnfollow: self.user!.uid, callback: { error in
                if error != nil  {
                    // Revert toggle button if failed
                    self.invertToggleFollowingButton()
                }
                UIViewController.removeSpinner(spinner: spinner)
            })
        } else {
            // Revert toggle button first for instant visual effect
            invertToggleFollowingButton()
            UserRelationManager.share.followUser(uidToFollow: self.user!.uid, callback: { error in
                if error != nil  {
                    // Revert toggle button if failed
                    self.invertToggleFollowingButton()
                }
                UIViewController.removeSpinner(spinner: spinner)
            })
        }
    }
    
    func invertToggleFollowingButton() {
        self.user!.isFollowing = !self.user!.isFollowing
        showToggleFollowingButton()
    }
    
    @objc func imageSelected () {
        if let imageSelectedCallback = self.avatarSelected  {
            imageSelectedCallback()
        }
    }
    
    @objc func nameSelected () {
        if let imageSelectedCallback = self.avatarSelected  {
            imageSelectedCallback()
        }
    }
}
