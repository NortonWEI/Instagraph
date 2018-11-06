//
//  PrimaryButton.swift
//  Instagraph
//
//  Created by Margareta  Hardiyanti on 09/09/18.
//  Copyright © 2018 Wenzhou Wei. All rights reserved.
//

import UIKit

class PrimaryButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = ColorObject.sharedInstance.purpleMainColor
        self.titleLabel?.font = FontObject.sharedInstance.header1Medium
        self .setTitleColor(UIColor.white, for: .normal)
        self.layer.cornerRadius = 8
    }
}
