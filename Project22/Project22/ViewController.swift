//
//  ViewController.swift
//  Project22
//
//  Created by adrian cordova y quiroz on 2/10/20.
//  Copyright © 2020 adrian cordova y quiroz. All rights reserved.
//

import UIKit
import CoreLocation


class ViewController: UIViewController,  CLLocationManagerDelegate {
    
    @IBOutlet var distanceReading: UILabel!
    //label on the ui
    //location manager object
    var locationManager: CLLocationManager?


    override func viewDidLoad() {
        super.viewDidLoad()
        
        //instantiate location manager
        locationManager = CLLocationManager()
        //make ourselves the delegate
        locationManager?.delegate = self
        //request for the users location
        locationManager?.requestAlwaysAuthorization()
        //when want to get location only when in use
        //locationManager?.requestWhenInUseAuthorization()

        //since unknown, make the view gray - wdk where the beacon is
        view.backgroundColor = .gray
        // Do any additional setup after loading the view.
    }
    
    //method to call when the user has made up their mind to change the authorization
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //they gave us permission to know their location
        if status == .authorizedAlways {
            //check if beacons are available
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                //check if the range is the available
                if CLLocationManager.isRangingAvailable() {
                    //start looking for the ibeacon
                    startScanning()
                }
            }
        }
    }
    
    func startScanning() {
        //known test beacon from apple
        let uuid = UUID(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5")!
        //uuid = identify you uniquely
        //major = subdivides uuids, (stores - unique major #)
        //minor = subdivides major, (departments in store - unique minor #)
//        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: 123, minor: 456, identifier: "MyBeacon")
        let beaconRegion = CLBeaconRegion(uuid: uuid, major: 123, minor: 456, identifier: "MyBeacon")

        locationManager?.startMonitoring(for: beaconRegion)
        locationManager?.startRangingBeacons(in: beaconRegion)
    }
    
    //func to update the view with a new color and text
    func update(distance: CLProximity) {
        UIView.animate(withDuration: 0.8) {
            switch distance {
            case .far:
                self.view.backgroundColor = UIColor.blue
                self.distanceReading.text = "FAR"

            case .near:
                self.view.backgroundColor = UIColor.orange
                self.distanceReading.text = "NEAR"

            case .immediate:
                self.view.backgroundColor = UIColor.red
                self.distanceReading.text = "RIGHT HERE"

            default:
                self.view.backgroundColor = UIColor.gray
                self.distanceReading.text = "UNKNOWN"
            }
        }
    }
    
    //func to update the location of the beacon
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if let beacon = beacons.first {
            update(distance: beacon.proximity)
        } else {
            update(distance: .unknown)
        }
    }


}

