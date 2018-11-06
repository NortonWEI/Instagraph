//
//  CommentTableViewCell.swift
//  Instagraph
//
//  Created by Margareta  Hardiyanti on 10/09/18.
//  Copyright © 2018 Wenzhou Wei. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
//    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameLeadingConstraint: NSLayoutConstraint!
    
    var avatarSelected : (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupViews()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setComment(name : String, content : String ) {
        self.commentLabel.text = content
        self.nameLabel.text = name
//        self.widthConstraint.constant = 0
        self.avatarImageView.isHidden = true
    }
    
    func setCommentWithAvatar(avatarUrl : String, name : String, content : String ) {
        self.commentLabel.text = content
        self.nameLabel.text = name
        self.avatarImageView.af_setImage(withURL: URL(string: avatarUrl)!)
    }
    
    func setupViews() {
        self.commentLabel.font = FontObject.sharedInstance.bodyCopy2
        self.commentLabel.textColor = ColorObject.sharedInstance.darkGray1
        self.nameLabel.font = FontObject.sharedInstance.bodyCopy2Bold
        self.nameLabel.textColor = ColorObject.sharedInstance.purpleMainColor
        self.avatarImageView.layer.cornerRadius = 15
        self.avatarImageView.clipsToBounds = true
        self.selectionStyle = .none
        
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(CommentTableViewCell.imageSelected))
        self.nameLabel.isUserInteractionEnabled = true
        self.nameLabel.addGestureRecognizer(tapGesture)
    }
    
    @objc func imageSelected () {
        if let imageSelectedCallback = self.avatarSelected  {
            imageSelectedCallback()
        }
    }
    
}
