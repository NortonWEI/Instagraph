//
//  FeedDetailViewController.swift
//  Instagraph
//
//  Created by Margareta  Hardiyanti on 17/10/18.
//  Copyright © 2018 Wenzhou Wei. All rights reserved.
//

import UIKit
import AlamofireImage
import MultiPeer

class FeedDetailViewController: UIViewController {
  
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var feedImageView: UIImageView!
    var imageUrl : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(FeedDetailViewController.panGestureValueChanged))
        self.cardView.addGestureRecognizer(panGesture)
        self.cardView.isUserInteractionEnabled = true
        self.feedImageView.af_setImage(withURL: URL(string: self.imageUrl)!)
        
        self.titleLabel.text = "Swipe this photo to share with your nearby friends!"
        self.titleLabel.textAlignment = .center
        self.titleLabel.font = FontObject.sharedInstance.bodyCopy1Bold
        self.titleLabel.textColor = ColorObject.sharedInstance.darkGray1
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    
    func setImageUrl(imageUrl : String) {
        self.imageUrl = imageUrl
    }
    
    @objc func panGestureValueChanged(_ sender: UIPanGestureRecognizer) {
        let cardView = sender.view!
        let translationPoint = sender.translation(in: view)
        cardView.center = CGPoint(x: view.center.x+translationPoint.x, y: view.center.y+translationPoint.y)
    
        if sender.state == UIGestureRecognizerState.ended {
            if cardView.center.x < view.frame.size.width/2 {
                UIView.animate(withDuration: 0.3, animations: {
                    cardView.center = CGPoint(x: cardView.center.x-500, y: cardView.center.y)
                    if let img = self.feedImageView.image {
                        let imgData = UIImagePNGRepresentation(img)
                        MultiPeer.instance.send(object: imgData as Any , type: 1)
                    }
                })
                return
            }
            else {
                UIView.animate(withDuration: 0.3, animations: {
                    cardView.center = CGPoint(x: cardView.center.x+500, y: cardView.center.y)
                    if let img = self.feedImageView.image {
                        let imgData = UIImagePNGRepresentation(img)
                        MultiPeer.instance.send(object: imgData as Any , type: 1)
                    }
                })
                return
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.cardView.isHidden = true
    }

}
