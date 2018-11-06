//
//  SecondaryButton.swift
//  Instagraph
//
//  Created by Margareta  Hardiyanti on 09/09/18.
//  Copyright © 2018 Wenzhou Wei. All rights reserved.
//

import UIKit

class SecondaryButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
         self.setTitleColor(ColorObject.sharedInstance.purpleMainColor, for: .normal)
    }

}
