//
//  ImageCollectionViewCell.swift
//  Instagraph
//
//  Created by Margareta  Hardiyanti on 16/09/18.
//  Copyright © 2018 Wenzhou Wei. All rights reserved.
//

import UIKit
import AlamofireImage

class ImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageView.contentMode = .scaleAspectFill
    }
    
    func setImageUrl(url : String) {
        self.imageView.af_setImage(withURL: URL(string: url)!)
    }

}
