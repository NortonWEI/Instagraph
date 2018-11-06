//
//  TertiaryButton.swift
//  Instagraph
//
//  Created by Margareta  Hardiyanti on 11/09/18.
//  Copyright © 2018 Wenzhou Wei. All rights reserved.
//

import UIKit

class TertiaryButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setTitleColor(ColorObject.sharedInstance.purpleMainColor, for: .normal)
        self.layer.borderColor = ColorObject.sharedInstance.purpleMainColor.cgColor
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 5.0
    }

}
