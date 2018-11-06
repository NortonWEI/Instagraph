//
//  Location.swift
//  Instagraph
//
//  Created by Dafu Ai on 18/9/18.
//  Copyright © 2018 Wenzhou Wei. All rights reserved.
//

import Foundation
import MapKit

class Location: FirebaseSerializable {
    var longitude: Double
    var latitude: Double
    var title: String
    
    required init(dict: NSDictionary) {
        self.longitude = dict["longitude"] as! Double
        self.latitude = dict["latitude"] as! Double
        self.title = dict["title"] as! String
    }
    
    func serialize() -> NSMutableDictionary {
        let dict = NSMutableDictionary()
        dict.setValue(self.longitude, forKey: "longitude")
        dict.setValue(self.latitude, forKey: "latitude")
        dict.setValue(self.title, forKey: "title")
        return dict
    }
    
    func getLocation() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(
            latitude: CLLocationDegrees(self.latitude),
            longitude: CLLocationDegrees(self.longitude)
        )
    }
}
