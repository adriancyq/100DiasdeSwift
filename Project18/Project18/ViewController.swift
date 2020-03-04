//
//  ViewController.swift
//  Project18
//
//  Created by adrian cordova y quiroz on 2/3/20.
//  Copyright © 2020 adrian cordova y quiroz. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("I'm inside the viewDidLoad() method!")
        //separator parameter separate every printed item
        print(1, 2, 3, 4, 5, separator: "-")
        //terminator is what should be at the end of the print statement
        print("Some message", terminator: "")
        
        //assertions force your app to crash when something isnt true
        //apple disables your assertions
        assert(1 == 1, "Maths success!")
//        assert(1 == 2, "Maths failure!")
        
//        assert(myReallySlowMethod() == true, "The slow method returned false, which is a bad thing!")
        
        //breakpoints
        //solid blue means its on
        //faint blue means its off but still there
        //right click to delete
        //fn f6 to step over the break point
        //continue = ctrl cmd y
        //cmd . is a full stop
        //make breakpoints conditional, right click use modulo %
        //exception break point, obj c, find the break point menu top right blocky arrow, click plus, exception breaker
        for i in 1 ... 100 {
            print("Got number \(i)")
        }

    }


}

