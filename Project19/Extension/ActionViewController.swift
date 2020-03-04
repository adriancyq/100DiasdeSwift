//
//  ActionViewController.swift
//  Extension
//
//  Created by adrian cordova y quiroz on 2/4/20.
//  Copyright © 2020 adrian cordova y quiroz. All rights reserved.
//

//type
//aler(document.title); into extension to get the title of the website to pop up in safari

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {
    @IBOutlet var script: UITextView!
    
    var pageTitle = ""
    var pageURL = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //make our own navigationItem barbutton item
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))

        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        

        //extension context is when the extension is made
        //inputItems is an array of data from parent app to extension (.first is the first item)
        if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem {
            //pull out attachment from first inputItem
            if let itemProvider = inputItem.attachments?.first {
                //asks the itemProvider to provide us with the data
                //dict contains what was provided to us by the app
                itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String) { [weak self] (dict, error) in
                    
                    //NSDictionary works like a swift dict, but you dont need to specify what the type is
                    guard let itemDictionary = dict as? NSDictionary else { return }
                    //typecast the js into an itemDictionary
                    guard let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { return }
                    //set the pageTitle var to the jsValues of title
                    self?.pageTitle = javaScriptValues["title"] as? String ?? ""
                    //set the pageURL var to the jsValues of URL
                    self?.pageURL = javaScriptValues["URL"] as? String ?? ""

                    //dispatch it back to the main
                    DispatchQueue.main.async {
                        self?.title = self?.pageTitle
                    }
                }
            }
        }
    }

    //inverse of viewdidLoad() to get the data from JS back to the view/app/ioS
    @IBAction func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        let item = NSExtensionItem()
        //script.text is the value of the text
        let argument: NSDictionary = ["customJavaScript": script.text]
        let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
        let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
        item.attachments = [customJavaScript]

        extensionContext?.completeRequest(returningItems: [item])
    }
    
    //takes a notification parameter
    @objc func adjustForKeyboard(notification: Notification) {
        //gives us the frame of the keyboardvalue, tells us the size of the keyboard
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        //read the size of the keyboard via a cgRectValue
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        //convert that rectangle to the views coordinates
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        //check if we are hiding or not
        if notification.name == UIResponder.keyboardWillHideNotification {
            //make sure the text view takes up all available space
            script.contentInset = .zero
        } else {
            //if we're in (did change frame) new type of contentInset making it stretch all the way across
            script.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }

        //how much margin is added to the scroller, match the size of the contentIntent
        script.scrollIndicatorInsets = script.contentInset

        //make the scroller move down so the user can read it
        let selectedRange = script.selectedRange
        script.scrollRangeToVisible(selectedRange)
    }
}
