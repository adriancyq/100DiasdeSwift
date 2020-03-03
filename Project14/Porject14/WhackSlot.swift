//
//  WhackSlot.swift
//  Porject14
//
//  Created by adrian cordova y quiroz on 1/22/20.
//  Copyright © 2020 adrian cordova y quiroz. All rights reserved.
//

import UIKit
//make sure to import for it to know what SKNode is
import SpriteKit

class WhackSlot: SKNode {
    
    var charNode: SKSpriteNode!
    var isVisible = false
    var isHit = false
    
    //makes whole for us at 
    func configure(at position: CGPoint) {
        self.position = position

        let sprite = SKSpriteNode(imageNamed: "whackHole")
        addChild(sprite)
        
        //add a property to your class in which we'll store the penguin picture node
        let cropNode = SKCropNode()
        cropNode.position = CGPoint(x: 0, y: 15)
        cropNode.zPosition = 1
        //if you wanna see the penguin
//        cropNode.maskNode = nil
        cropNode.maskNode = SKSpriteNode(imageNamed: "whackMask")

        charNode = SKSpriteNode(imageNamed: "penguinGood")
        charNode.position = CGPoint(x: 0, y: -90)
        charNode.name = "character"
        cropNode.addChild(charNode)

        addChild(cropNode)
    }
    
    //func
    func show(hideTime: Double) {
        //if isVisible is true then return
        if isVisible { return }
        
        //reset scales after 1 since were modified
        charNode.xScale = 1
        charNode.yScale = 1

        //80 points up, and move by .05 which is really fast
        charNode.run(SKAction.moveBy(x: 0, y: 80, duration: 0.05))
        //the penguin is now seen
        isVisible = true
        //but has not been hit yet
        isHit = false

        //decides if it's a good penguin or a bad penguin, 0,1,2 gives it a 1/3 chance
        if Int.random(in: 0...2) == 0 {
            //makes the node a goodpenguin
            charNode.texture = SKTexture(imageNamed: "penguinGood")
            charNode.name = "charFriend"
        } else {
            //makes the penguin bad
            charNode.texture = SKTexture(imageNamed: "penguinEvil")
            charNode.name = "charEnemy"
        }
        
        //call the hide()method after sometime
        DispatchQueue.main.asyncAfter(deadline: .now() + (hideTime * 3.5)) { [weak self] in
            self?.hide()
        }
    }
    
    func hide() {
        //if not visible then already hidden
        if !isVisible { return }

        charNode.run(SKAction.moveBy(x: 0, y: -80, duration: 0.05))
        //it's now visible and hit
        isVisible = false
    }
    
    //func for when penguin is hit
    func hit() {
        //we know the peng has been whacked
        isHit = true
        
        //w8 quarter of a second
        let delay = SKAction.wait(forDuration: 0.25)
        //hide the peng after it's been hit
        let hide = SKAction.moveBy(x: 0, y: -80, duration: 0.5)
        //make sure isVisible is now false cause it was hit
        let notVisible = SKAction.run { [unowned self] in self.isVisible = false }
        //hides and makes invisible
        charNode.run(SKAction.sequence([delay, hide, notVisible]))
    }

}
