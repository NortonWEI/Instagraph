//
//  PopupImageViewController.swift
//  Instagraph
//
//  Created by Margareta  Hardiyanti on 18/10/18.
//  Copyright © 2018 Wenzhou Wei. All rights reserved.
//

import UIKit

class PopupImageViewController: UIViewController {

    @IBOutlet weak var feedImageView: UIImageView!
    @IBOutlet weak var noButton: PrimaryButton!
    @IBOutlet weak var yesButton: PrimaryButton!
    @IBOutlet weak var questionLabel: UILabel!
    var img : UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.noButton .setTitle("No", for: .normal)
        self.yesButton.setTitle("Yes", for: .normal)
        self.questionLabel.font = FontObject.sharedInstance.bodyCopy1
        self.questionLabel.text = "Would you like to save this image?"
        self.feedImageView.image = self.img
        self.yesButton.addTarget(self, action: #selector(PopupImageViewController.saveImage), for: .touchUpInside)
        self.noButton.addTarget(self, action: #selector(PopupImageViewController.dismissPage), for: .touchUpInside)
        self.questionLabel.textColor = ColorObject.sharedInstance.darkGray1
    }
    
    func setImage(image: UIImage) {
        self.img = image
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func dismissPage() {
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc func saveImage() {
        let alertController = UIAlertController(title: "Successful", message: "The photo has been saved to your library!", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (alert) in
            UIImageWriteToSavedPhotosAlbum(self.img, nil, nil, nil);
            self.dismiss(animated: false, completion: nil)
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
