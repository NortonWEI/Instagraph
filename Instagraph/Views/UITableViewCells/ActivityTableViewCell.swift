//
//  ActivityTableViewCell.swift
//  Instagraph
//
//  Created by LI MINCHENG on 17/9/18.
//  Copyright © 2018 Wenzhou Wei. All rights reserved.
//

import UIKit

class ActivityTableViewCell: UITableViewCell {

    @IBOutlet weak var AvatorImg: UIImageView!
    @IBOutlet weak var PhotoImg: UIImageView!
    @IBOutlet weak var ContentTxt: UILabel!
    @IBOutlet weak var TimestampTxt: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
