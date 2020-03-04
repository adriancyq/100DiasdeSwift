//
//  GameViewController.swift
//  Project 20
//
//  Created by adrian cordova y quiroz on 2/5/20.
//  Copyright © 2020 adrian cordova y quiroz. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //func to check when the phone has been shaken
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        //make sure the view is an SKView
        guard let skView = view as? SKView else { return }
        //make sure our view shows that game scene
        guard let gameScene = skView.scene as? GameScene else { return }
        //if so, then call explodeFireworks() on the game scene when the device is shaken
        gameScene.explodeFireworks()
    }
}
