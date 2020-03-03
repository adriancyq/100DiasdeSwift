//
//  ViewController.swift
//  Project15
//
//  Created by adrian cordova y quiroz on 1/23/20.
//  Copyright © 2020 adrian cordova y quiroz. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var imageView: UIImageView!
    var currentAnimation = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //using an initializer that takes a UIImage and makes the image view the correct size for the image
        imageView = UIImageView(image: UIImage(named: "penguin"))
        imageView.center = CGPoint(x: 512, y: 384)
        view.addSubview(imageView)
    }

    @IBAction func tapped(_ sender: UIButton) {
        //hide tapped button when animation starts
        sender.isHidden = true

    //animation block, duration (seconds), delay(seconds), options[no options passedin], completion handler
        //UIView.animate(withDuration: 1, delay: 0, options: [],
        //0.5 makes it quite springy, 5 is a medium spring velocity
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: [],
           animations: {
        
            //closure to prepare animation
            //read the current animation value
            switch self.currentAnimation {
            case 0:
                //transform the image view into twice its size
                self.imageView.transform = CGAffineTransform(scaleX: 2, y: 2)
                
            case 1:
                //clears out the imageView by modifiying it's transform property //reset transform
                //size back to normal
                self.imageView.transform = .identity
                
            case 2:
                //tranforms the image view 256 points to the left and 256 up
                self.imageView.transform = CGAffineTransform(translationX: -256, y: -256)

            case 3:
                //clears out the imageView by modifiying it's transform property //reset transform
                //moves back to center
                self.imageView.transform = .identity
                
            case 4:
                //rotate the image view over pi
                self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                
            case 5:
                //clears out the imageView by modifiying it's transform property //reset transform
                self.imageView.transform = .identity
                
            case 6:
                //transparency of background
                self.imageView.alpha = 0.1
                //make the background green
                self.imageView.backgroundColor = UIColor.green

            case 7:
                //reset the transparency of background
                self.imageView.alpha = 1
                //clear the background color
                self.imageView.backgroundColor = UIColor.clear
            
            default:
                break
            }
            //closure once finished
            //once complete then unhide the tap button
        }) { finished in
            sender.isHidden = false
        }
        
        //cycle through animations when button tapped
        currentAnimation += 1

        if currentAnimation > 7 {
            currentAnimation = 0
        }
    }
}

