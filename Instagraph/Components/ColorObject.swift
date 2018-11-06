//
//  ColorObject.swift
//  Instagraph
//
//  Created by Margareta  Hardiyanti on 09/09/18.
//  Copyright © 2018 Wenzhou Wei. All rights reserved.
//

import UIKit

class ColorObject: NSObject {
    
    static let sharedInstance = ColorObject()
    let purpleMainColor = UIColor.init(red: 115.0/255.0, green: 117/255, blue: 161/255, alpha: 1.0)

    let lightBlack = UIColor(red:32.0/255.0, green:32.0/255.0, blue:32.0/255.0, alpha:1.0)
    let darkGray1 = UIColor(red:0.33, green:0.33, blue:0.33, alpha:1.0)
    let darkGray2 = UIColor(red:0.42, green:0.40, blue:0.40, alpha:1.0)
    let grayButtonColor =  UIColor(red:170/255.0, green:170/255.0, blue:170/255.0, alpha:1.0)
    let gray = UIColor(red:0.61, green:0.61, blue:0.61, alpha:1.0)
    let gray2 = UIColor(red:152/255.0, green:152/255.0, blue:152/255.0, alpha:1.0)
    let gray3 = UIColor(red:217/255.0, green:216/255.0, blue:216/255.0, alpha:1.0)
    let gray4 = UIColor(red:132/255.0, green:132/255.0, blue:132/255.0, alpha:1.0)
}
