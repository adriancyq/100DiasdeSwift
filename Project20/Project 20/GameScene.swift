//
//  GameScene.swift
//  Project 20
//
//  Created by adrian cordova y quiroz on 2/5/20.
//  Copyright © 2020 adrian cordova y quiroz. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    //the label for the score on the screen
    var gameScore: SKLabelNode!
    //timer for the game
    var gameTimer: Timer?
    //array of SKNode fireworks
    var fireworks = [SKNode]()

    //edges of the screen to launch fireworks from
    let leftEdge = -22
    let bottomEdge = -22
    let rightEdge = 1024 + 22

    //track the players score
    var score = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    override func didMove(to view: SKView) {
        //background with image named
        let background = SKSpriteNode(imageNamed: "background")
        //position background in the middle
        background.position = CGPoint(x: 512, y: 384)
        //blend in since opaque
        background.blendMode = .replace
        //place it behind everything
        background.zPosition = -1
        addChild(background)
        
        //creates our score object
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.text = "Score: 0"
        gameScore.position = CGPoint(x: 8, y: 8)
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        addChild(gameScore)

        //gameTimer
        gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)
        
    }
    
    //creates fireworks for us
    func createFirework(xMovement: CGFloat, x: Int, y: Int) {
        //Create an SKNode that will act as the firework container, and place it at the position that was specified.
        let node = SKNode()
        node.position = CGPoint(x: x, y: y)

        //Create a rocket sprite node, give it the name "firework" so we know that it's the important thing, adjust its colorBlendFactor property so that we can color it, then add it to the container node
        let firework = SKSpriteNode(imageNamed: "rocket")
        firework.colorBlendFactor = 1
        firework.name = "firework"
        node.addChild(firework)

        //Give the firework sprite node one of three random colors: cyan, green or red. I've chosen cyan because pure blue isn't particularly visible on a starry sky background picture
        switch Int.random(in: 0...2) {
        case 0:
            firework.color = .cyan

        case 1:
            firework.color = .green

        case 2:
            firework.color = .red

        default:
            break
        }

        //Create a UIBezierPath that will represent the movement of the firework
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: xMovement, y: 1000))

        //Tell the container node to follow that path, turning itself as needed
        let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200)
        node.run(move)

        //Create particles behind the rocket to make it look like the fireworks are lit
        if let emitter = SKEmitterNode(fileNamed: "fuse") {
            emitter.position = CGPoint(x: 0, y: -22)
            node.addChild(emitter)
        }

        //Add the firework to our fireworks array and also to the scene
        fireworks.append(node)
        addChild(node)
    }
    
    @objc func launchFireworks() {
        let movementAmount: CGFloat = 1800

        //make 4 different types of fireworks
        switch Int.random(in: 0...3) {
        case 0:
            // fire five, straight up
            createFirework(xMovement: 0, x: 512, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 - 200, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 - 100, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 + 100, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 + 200, y: bottomEdge)

        case 1:
            // fire five, in a fan
            createFirework(xMovement: 0, x: 512, y: bottomEdge)
            createFirework(xMovement: -200, x: 512 - 200, y: bottomEdge)
            createFirework(xMovement: -100, x: 512 - 100, y: bottomEdge)
            createFirework(xMovement: 100, x: 512 + 100, y: bottomEdge)
            createFirework(xMovement: 200, x: 512 + 200, y: bottomEdge)

        case 2:
            // fire five, from the left to the right
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 400)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 300)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 200)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 100)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge)

        case 3:
            // fire five, from the right to the left
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 400)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 300)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 200)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 100)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge)

        default:
            break
        }
    }
    
    //checks the nodes the user touches
    func checkTouches(_ touches: Set<UITouch>) {
        //bail out if no touch found
        guard let touch = touches.first else { return }

        //get the location of the touch
        let location = touch.location(in: self)
        //get all the spritekit nodes at the location
        let nodesAtPoint = nodes(at: location)

        //loop through all the nodes at that location and find the locations
        for case let node as SKSpriteNode in nodesAtPoint {
            //if the name of the node is a firework, else get out of here
            guard node.name == "firework" else { continue }
            //the name of the node is now selected
            node.name = "selected"
            //parent is the first firework selected in the fireworks array
            for parent in fireworks {
                //make sure the first is a skspritenode
                guard let firework = parent.children.first as? SKSpriteNode else { continue }
                //if it has been selected and the color is not the same as the other colors in the []
                if firework.name == "selected" && firework.color != node.color {
                    //reset it to a firework
                    firework.name = "firework"
                    //set the colorblend back to 1
                    firework.colorBlendFactor = 1
                }
            }
            //if not the firework has been selected correctly
            node.colorBlendFactor = 0
        }
    }
    
    //get the first touch from the user and send it to check touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        checkTouches(touches)
    }

    //get the touchesmoved from the user and send it to check touches
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        checkTouches(touches)
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        //loop over all the fireworks with enumerated to get index and value and reverse it
        for (index, firework) in fireworks.enumerated().reversed() {
            //make sure the position of the fireworks is above 900
            if firework.position.y > 900 {
                // this uses a position high above so that rockets can explode off screen
                fireworks.remove(at: index)
                firework.removeFromParent()
            }
        }
    }
    
    //explode a firework
    func explode(firework: SKNode) {
        //make sure the emitter loads the explode noise
        if let emitter = SKEmitterNode(fileNamed: "explode") {
            //place the emitter at the position of the firework
            emitter.position = firework.position
            addChild(emitter)
        }
        
        //remove firework from scene
        firework.removeFromParent()
    }
    
    //explode multiple fireworks
    func explodeFireworks() {
        //number of fireworks exploded
        var numExploded = 0

        //loop through fireworks array, and destroy the selected ones
        for (index, fireworkContainer) in fireworks.enumerated().reversed() {
            //read out the first child from the node
            guard let firework = fireworkContainer.children.first as? SKSpriteNode else { continue }
            
            //if firework is selected
            if firework.name == "selected" {
                // destroy this firework! the container node for the sprite node and emitter node
                explode(firework: fireworkContainer)
                //remove at the index
                fireworks.remove(at: index)
                numExploded += 1
            }
        }

        //points for exploding the fireworks
        switch numExploded {
        case 0:
            // nothing – rubbish!
            break
        case 1:
            score += 200
        case 2:
            score += 500
        case 3:
            score += 1500
        case 4:
            score += 2500
        default:
            score += 4000
        }
    }
}
