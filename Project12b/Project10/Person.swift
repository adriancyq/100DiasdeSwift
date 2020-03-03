//
//  Person.swift
//  Project10
//
//  Created by adrian cordova y quiroz on 1/18/20.
//  Copyright © 2020 adrian cordova y quiroz. All rights reserved.
//

import UIKit

class Person: NSObject, Codable {
    var name: String
    var image: String
    
    init(name: String, image: String){
        self.name = name
        self.image = image
    }

}
