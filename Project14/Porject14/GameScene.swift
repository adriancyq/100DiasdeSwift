//
//  GameScene.swift
//  Porject14
//
//  Created by adrian cordova y quiroz on 1/22/20.
//  Copyright © 2020 adrian cordova y quiroz. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    //the label for the score on the screen
    var gameScore: SKLabelNode!
    //array to hold the slots
    var slots = [WhackSlot]()
    
    //time it takes for a penguin to pop up
    var popupTime = 0.85
    
    var numRounds = 0
    
    //players internal score, updates when changed
    var score = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        //sets background
        let background = SKSpriteNode(imageNamed: "whackBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)

        //creates our score object
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.text = "Score: 0"
        gameScore.position = CGPoint(x: 8, y: 8)
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        addChild(gameScore)
        
        //positions slots in corresponding areas
        for i in 0 ..< 5 { createSlot(at: CGPoint(x: 100 + (i * 170), y: 410)) }
        for i in 0 ..< 4 { createSlot(at: CGPoint(x: 180 + (i * 170), y: 320)) }
        for i in 0 ..< 5 { createSlot(at: CGPoint(x: 100 + (i * 170), y: 230)) }
        for i in 0 ..< 4 { createSlot(at: CGPoint(x: 180 + (i * 170), y: 140)) }
        
        //call create in after 1 second too
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.createEnemy()
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //if you cant read the touch that came in bail out
        guard let touch = touches.first else { return }
        //gets where they tapped the screen
        let location = touch.location(in: self)
        //all the sknodes at that location
        let tappedNodes = nodes(at: location)
        //finds out if it's a friend or enemy peng
        for node in tappedNodes {
            //try and read the gparent of node that was whacked, if fails then ignore and
            guard let whackSlot = node.parent?.parent as? WhackSlot else { continue }
            //if it was not visible, forget about it
            if !whackSlot.isVisible { continue }
            //if it was hit, forget about it and go to next one
            if whackSlot.isHit { continue }
            whackSlot.hit()

            if node.name == "charFriend" {
                // they shouldn't have whacked this penguin
                score -= 5

                run(SKAction.playSoundFileNamed("whackBad.caf", waitForCompletion: false))
            } else if node.name == "charEnemy" {
                // they should have whacked this one
                whackSlot.charNode.xScale = 0.85
                whackSlot.charNode.yScale = 0.85
                score += 1

                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
            }
        }
    }
    
    //method, then adds the slot both to the scene and to our array
    func createSlot(at position: CGPoint) {
        let slot = WhackSlot()
        slot.configure(at: position)
        addChild(slot)
        slots.append(slot)
    }
    
    func createEnemy() {
        //add a round every time an enemy is created
        numRounds += 1

        //have now made 30 rounds
        //hide all the slots
        if numRounds >= 30 {
            for slot in slots {
                slot.hide()
            }

            //show game over in the middle of the screen
            let gameOver = SKSpriteNode(imageNamed: "gameOver")
            gameOver.position = CGPoint(x: 512, y: 384)
            gameOver.zPosition = 1
            addChild(gameOver)

            return
        }
        //makes the popup time smaller as time goes on
        popupTime *= 0.991
        
        //shuffle slots array
        slots.shuffle()
        //show the first penguin at normal popuptime
        slots[0].show(hideTime: popupTime)
        
        //sometimes show a second, 3rd, 4th, 5th slot
        if Int.random(in:0...12) > 4 {slots[1].show(hideTime: popupTime)}
        if Int.random(in:0...12) > 8 {slots[2].show(hideTime: popupTime)}
        if Int.random(in:0...12) > 10 {slots[3].show(hideTime: popupTime)}
        if Int.random(in:0...12) > 11 {slots[4].show(hideTime: popupTime)}
        
        //call create enemy after a certain period of time
        //minimum delay is half of the popup time
        let minDelay = popupTime / 2.0
        //max delay is twice of the popup time
        let maxDelay = popupTime * 2
        //the actual delay
        let delay = Double.random(in: minDelay...maxDelay)

        //calls createEnemy() after a certain amount of time
        //deadline parameter is now + our delay
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.createEnemy()
        }
    }
}
