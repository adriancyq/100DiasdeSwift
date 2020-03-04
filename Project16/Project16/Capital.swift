//
//  Capital.swift
//  Project16
//
//  Created by adrian cordova y quiroz on 1/24/20.
//  Copyright © 2020 adrian cordova y quiroz. All rights reserved.
//

import UIKit
import MapKit

//MKannotation defines a place on a map
class Capital: NSObject, MKAnnotation {
    
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var info: String

    //initializer, with previous info
    init(title: String, coordinate: CLLocationCoordinate2D, info: String) {
        self.title = title
        self.coordinate = coordinate
        self.info = info
    }
}
