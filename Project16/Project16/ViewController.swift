//
//  ViewController.swift
//  Project16
//
//  Created by adrian cordova y quiroz on 1/24/20.
//  Copyright © 2020 adrian cordova y quiroz. All rights reserved.
//

import UIKit
import MapKit

//conforms to MKMapViewDelegate
class ViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //making Capital objects with their name, coordinate, and info
        let london = Capital(title: "London", coordinate: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), info: "Lost to the free folk of the 13 colonies.")
        let oslo = Capital(title: "Oslo", coordinate: CLLocationCoordinate2D(latitude: 59.95, longitude: 10.75), info: "Birthplace of our lord and savior Kygo.")
        let paris = Capital(title: "Paris", coordinate: CLLocationCoordinate2D(latitude: 48.8567, longitude: 2.3508), info: "The city of gays.")
        let rome = Capital(title: "Rome", coordinate: CLLocationCoordinate2D(latitude: 41.9, longitude: 12.5), info: "Was for sure built in one day.")
        let washington = Capital(title: "Washington DC", coordinate: CLLocationCoordinate2D(latitude: 38.895111, longitude: -77.036667), info: "Capital of the greatest nation on Earth.")
        
        //send to mapview for display with addAnnotation
//        mapView.addAnnotation(london)
//        mapView.addAnnotation(oslo)
//        mapView.addAnnotation(paris)
//        mapView.addAnnotation(rome)
//        mapView.addAnnotation(washington)
        
        //or
        mapView.addAnnotations([london, oslo, paris, rome, washington])

    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // If the annotation isn't from a capital city, it must return nil so iOS uses a default view
        guard annotation is Capital else { return nil }

        // Define a reuse identifier. This is a string that will be used to ensure we reuse annotation views as much as possible.
        let identifier = "Capital"

        // Try to dequeue an annotation view from the map view's pool of unused views
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            //If it isn't able to find a reusable view, create a new one using MKPinAnnotationView and sets its canShowCallout property to true. This triggers the popup with the city name.
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true

            // Create a new UIButton using the built-in .detailDisclosure type. This is a small blue "i" symbol with a circle around it.
            let btn = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = btn
        } else {
            // If it can reuse a view, update that view to use a different annotation
            annotationView?.annotation = annotation
        }

        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //make sure annotation is a capital
        guard let capital = view.annotation as? Capital else { return }
        //get the name of the capital
        let placeName = capital.title
        //get the info of the capital
        let placeInfo = capital.info
        
        //make alert controller with place name, place info, .alert default style
        let ac = UIAlertController(title: placeName, message: placeInfo, preferredStyle: .alert)
        //add action
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        //present it : D
        present(ac, animated: true)
    }


}

