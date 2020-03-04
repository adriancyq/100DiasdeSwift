//
//  ViewController.swift
//  Project 28
//
//  Created by adrian cordova y quiroz on 2/29/20.
//  Copyright © 2020 adrian cordova y quiroz. All rights reserved.
//

import UIKit
//touch and face id
import LocalAuthentication

class ViewController: UIViewController {
    
    @IBOutlet var secret: UITextView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //create a notification center
        let notificationCenter = NotificationCenter.default
        //keyboard hides the notofication
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        //keyboard changes frame notification
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        // when our app has been backgrounded or the user has switched to multitasking mode
        //call saveSecretMessage when the user leaves or switches app
        notificationCenter.addObserver(self, selector: #selector(saveSecretMessage), name: UIApplication.willResignActiveNotification, object: nil)

        
        title = "You dont have access m8"
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        //once we get a notification, get the keyboard value
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        //pull out thevalues from the keyboard
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        //convert the view of the keyboard frame to our views coordinates
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        //are we hiding or not? make our secret textview be the full screen
        if notification.name == UIResponder.keyboardWillHideNotification {
            secret.contentInset = .zero
        } else {
            //show the secret text field
            secret.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }

        //allow to scroll with scroll bar
        secret.scrollIndicatorInsets = secret.contentInset

        //scroll it back to wherever it was selected
        let selectedRange = secret.selectedRange
        secret.scrollRangeToVisible(selectedRange)
    }
    
    //unlocks our secret message
    func unlockSecretMessage() {
        secret.isHidden = false
        title = "Secret message m8!"
        
        //try loading that key from a keychain
        if let text = KeychainWrapper.standard.string(forKey: "SecretMessage") {
            //put that text in our text view
            secret.text = text
        }
    }
    
    //saves the user's secret message
    @objc func saveSecretMessage() {
        //only execute if text is visible
        guard secret.isHidden == false else { return }

        //write our string to the keychain
        KeychainWrapper.standard.set(secret.text, forKey: "SecretMessage")
        //make the text view stop being active on the screen
        secret.resignFirstResponder()
        //hide the text view
        secret.isHidden = true
        title = "You dont have access m8"
    }
    
    
    @IBAction func authenticateTapped(_ sender: Any) {
        //local authentication contexst
        let context = LAContext()
        //stores error if something goes wrong
        //objective C of a swift error type
        var error: NSError?

        //can we use biometric authentication or not
        //&error means pass in where that error is in RAM
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself m8!"

            //use the biometric policy
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                [weak self] success, authenticationError in

                //put it on the main thread
                DispatchQueue.main.async {
                    //call the secret message func
                    if success {
                        self?.unlockSecretMessage()
                    } else {
                        // error, we tried to authenticate but it didnt work
                        let ac = UIAlertController(title: "Authentication failed", message: "You could not be verified m8; give it another go.", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        //pass it back to the view controller
                        self?.present(ac, animated: true)
                    }
                }
            }
        } else {
            // no biometry possible
            let ac = UIAlertController(title: "Biometry aint there amigo", message: "Your device is not configured for biometric authentication - aka ur phone's old", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    

}

