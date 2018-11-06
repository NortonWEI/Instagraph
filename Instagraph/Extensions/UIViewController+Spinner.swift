//
//  UIViewController+Spinner.swift
//  Instagraph
//
//  Created by Dafu Ai on 12/9/18.
//  Copyright © 2018 Wenzhou Wei. All rights reserved.
//

import UIKit

extension UIViewController {
    // Credit: http://brainwashinc.com/2017/07/21/loading-activity-indicator-ios-swift/
    class func displaySpinner(onView : UIView) -> UIView {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        return spinnerView
    }
    
    class func removeSpinner(spinner :UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
}
