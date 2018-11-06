//
//  PictureCellTableViewCell.swift
//  Instagraph
//
//  Created by Margareta  Hardiyanti on 10/09/18.
//  Copyright © 2018 Wenzhou Wei. All rights reserved.
//

import UIKit
import AlamofireImage
import Firebase

class PictureCellTableViewCell: UITableViewCell {
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var toggleLikeButton: UIButton!
    @IBOutlet weak var feedLabelsLabel: UILabel!
    
    weak var tableView: UITableView?
    var feed: UserFeed?
    var user: FirebaseUser?
    
    var avatarSelected : (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupViews()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setFeed(feed: UserFeed, user: FirebaseUser, tableView: UITableView) {
        self.feed = feed
        self.user = user
        self.tableView = tableView
        self.pictureImageView.image = feed.image
        self.avatarImageView.image = user.image
        self.nameLabel.text = user.name
        self.timeLabel.text = Timestamp.historicDateToReadable(dateFrom: feed.getDate())
        
        let distText = feed.getDistToCurrUser() != nil ? (" (" + feed.getReadableDistToCurrUser() + ")") : ""
        self.locationLabel.text = (feed.location != nil ? feed.location!.title : "") + distText
        self.feedLabelsLabel.text = feed.getLabelsInSingleString()
        self.updateLikesCount()
        self.updateToogleLikeButton()
    }
    
    func setupViews() {
        self.nameLabel.font = FontObject.sharedInstance.bodyCopy1Bold
        self.nameLabel.textColor = ColorObject.sharedInstance.darkGray1
        self.pictureImageView.contentMode = .scaleAspectFill
        self.avatarImageView.contentMode = .scaleAspectFill
        self.avatarImageView.layer.cornerRadius = 20
        self.avatarImageView.clipsToBounds = true
        self.selectionStyle = .none
        
        self.locationLabel.font = FontObject.sharedInstance.bodyCopy2
        self.locationLabel.textColor = ColorObject.sharedInstance.purpleMainColor
        self.likesLabel.font = FontObject.sharedInstance.bodyCopy2
        self.likesLabel.textColor = ColorObject.sharedInstance.darkGray1
        
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(PictureCellTableViewCell.nameSelected))
        self.nameLabel.isUserInteractionEnabled = true
        self.nameLabel.addGestureRecognizer(tapGesture)
        
        let avatarTapGesture = UITapGestureRecognizer()
        avatarTapGesture.addTarget(self, action: #selector(PictureCellTableViewCell.imageSelected))
        self.avatarImageView.isUserInteractionEnabled = true
        self.avatarImageView.addGestureRecognizer(avatarTapGesture)
    }
    
    func updateLikesCount() {
        let likesCount = self.feed!.likes.values.count
        if likesCount == 0 {
            self.likesLabel.text = "Be the first to like this feed"
        } else {
            if self.feed!.isLikedByCurrUser() {
                if likesCount == 1 {
                    self.likesLabel.text = "Only you liked this feed"
                } else {
                    self.likesLabel.text = "You and " + String(likesCount-1) + " other people liked this feed"
                }
            } else {
                self.likesLabel.text = String(likesCount) + " people liked this feed"
            }
        }
    }
    
    func updateToogleLikeButton() {
        guard self.feed != nil else {
            return
        }
        
        self.updateLikesCount()
        if self.feed!.isLikedByCurrUser() {
            self.toggleLikeButton.setImage(UIImage(named: "liked"), for: .normal)
        } else {
            self.toggleLikeButton.setImage(UIImage(named: "like"), for: .normal)
        }
    }
    
    @IBAction func toggleLikeButtonClicked(_ sender: Any) {
        let feed = self.feed!
        
        if feed.isLikedByCurrUser() {
            feed.unlike(callback: { (error) in
                guard error == nil else {
                    return
                }
                
                self.updateToogleLikeButton()
            })
        } else {
            feed.like(callback: { (error) in
                guard error == nil else {
                    return
                }
                
                self.updateToogleLikeButton()
            })
        }
    }
    
    @IBAction func enterCommentButtonClicked(_ sender: Any) {
        feed!.isCommenting = !feed!.isCommenting
        self.tableView?.reloadData()
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
