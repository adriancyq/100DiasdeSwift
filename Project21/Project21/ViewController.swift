//
//  ViewController.swift
//  Project21
//
//  Created by adrian cordova y quiroz on 2/6/20.
//  Copyright © 2020 adrian cordova y quiroz. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UNUserNotificationCenterDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //the buttons
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(registerLocal))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(scheduleLocal))
        // Do any additional setup after loading the view.
    }
    
    //gets permission from user to send notifications
    @objc func registerLocal() {
        let center = UNUserNotificationCenter.current()

        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Yay!")
            } else {
                print("D'oh")
            }
        }
    }

    //func for what the notificatino says
    @objc func scheduleLocal() {
        registerCategories()
        //get access to current user notification center
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        //post some content to the user notification
        let content = UNMutableNotificationContent()
        content.title = "Late wakeup call"
        content.body = "GET UP BRO ITS LATE"
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.default
        
        //trigger for when the notification goes off
        //datecomponents object
        var dateComponents = DateComponents()
        //10am
        dateComponents.hour = 10
        //30 minutes
        dateComponents.minute = 30
        //wrap inside a calendar notification trigger, repeats true is every morning
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        //time interval trigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        //request that ties the content and the trigger together
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        //add the request to the notification center
        center.add(request)
    }
    
    func registerCategories() {
        //get access to current user notification center
        let center = UNUserNotificationCenter.current()
        //assign delegate to current view controller UNUserNotificationCenterDelegate
        center.delegate = self

        //show a notification to tell me more, title is user facing
        let show = UNNotificationAction(identifier: "show", title: "Tell me more…", options: .foreground)
        let category = UNNotificationCategory(identifier: "alarm", actions: [show], intentIdentifiers: [])

        //set the notification categories
        center.setNotificationCategories([category])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // pull out the buried userInfo dictionary
        //read out our custom string
        let userInfo = response.notification.request.content.userInfo

        //if we can read the custom user key in the data then pring the data received
        if let customData = userInfo["customData"] as? String {
            print("Custom data received: \(customData)")

            //what'd the user do with the notification
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                // the user swiped to unlock
                print("Default identifier")

            case "show":
                // the user tapped our "show more info…" button
                print("Show more information…")

            default:
                break
            }
        }

        // you must call the completion handler when you're done
        completionHandler()
    }

}

