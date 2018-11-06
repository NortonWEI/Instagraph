//
//  AddCommentTableViewCell.swift
//  Instagraph
//
//  Created by Margareta  Hardiyanti on 10/09/18.
//  Copyright © 2018 Wenzhou Wei. All rights reserved.
//

import UIKit
import UITextView_Placeholder

class AddCommentTableViewCell: UITableViewCell {

    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var postButton: PrimaryButton!
    
    var feed: UserFeed?
    weak var tableView: UITableView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.postButton .setTitle("Post", for: .normal)
        self.commentTextView.placeholder = "Write a comment"
        self.commentTextView.layer.borderWidth = 1.0
        self.commentTextView.layer.cornerRadius = 5.0
        self.commentTextView.layer.borderColor = ColorObject.sharedInstance.gray.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setFeed(feed: UserFeed, tableView: UITableView) {
        self.feed = feed
        self.tableView = tableView
    }
    
    @IBAction func postCommentButtonClicked(_ sender: Any) {
        let text = self.commentTextView.text!.trimmingCharacters(in: CharacterSet.whitespaces)
        if text.count > 0 {
            let spinner = UIViewController.displaySpinner(onView: self)
            feed!.addComment(text: text) { (error) in
                guard error == nil else {
                    UIViewController.removeSpinner(spinner: spinner)
                    return
                }
                
                UIViewController.removeSpinner(spinner: spinner)
                self.feed!.isCommenting = false
                self.tableView?.reloadData()
            }
        }
    }
}
