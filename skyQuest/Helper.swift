//
//  Helper.swift
//  skyQuest
//
//  Created by Jessica M Cavazos Erhard on 9/28/16.
//  Copyright © 2016 itesm. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class User {
    var id: String?
    var pins: [String:MKPointAnnotation] = [:]
    
    init(id:String) {
        self.id = id
    }
    
    //Function to change annotation of place.
    func changepinLocation(pinTitle: String, lat: String, lon: String){
        let newCoordinate = CLLocationCoordinate2D(latitude: Double(lat)! , longitude: Double(lon)!)
        pins[pinTitle]?.coordinate = newCoordinate
    }
}

let user = User(id: "5")


