//
//  UserLocationManager.swift
//  Instagraph
//
//  Created by Dafu Ai on 20/9/18.
//  Copyright © 2018 Wenzhou Wei. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class UserLocationManager: NSObject, CLLocationManagerDelegate {
    static let share = UserLocationManager()
    
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    
    private override init() {
        self.locationManager = CLLocationManager()
        super.init()
    }
    
    func initializeService() {
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }
    
    func displayAlert(vc: UIViewController) {
        let alertController = UIAlertController(title: nil, message: "Location data unavailable", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        vc.present(alertController, animated: true, completion: nil)
    }
}
