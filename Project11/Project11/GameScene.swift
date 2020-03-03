//
//  GameScene.swift
//  Project11
//
//  Created by adrian cordova y quiroz on 1/18/20.
//  Copyright © 2020 adrian cordova y quiroz. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    //makes our score label
    var scoreLabel: SKLabelNode!
    //keeps score for us and updates the label when score changes
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    //makes edit label
    var editLabel: SKLabelNode!
    //if we are in edit label or not
    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        //make it completely solid
        background.blendMode = .replace
        //place behind everything else
        background.zPosition = -1
        addChild(background)
        
        //makes our scorelabel, font, position, size, and adds to screen
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        //makes the edit label, font, position, size, etc
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
        
        //drops the box on the screen
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        //Then assign the current scene to be the physics world's contact delegate
        physicsWorld.contactDelegate = self
        
        
        //makes the slots and says whether they are good or bad
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
        
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))

    }
    
    //called when users touch the screen somehow
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //get the first touch on the screen
        guard let touch = touches.first else {return}
        //show me where that first touch was in the whole game scene
        let location = touch.location(in: self)
        
        let objects = nodes(at: location)

        if objects.contains(editLabel) {
            //flips the boolean value
            editingMode.toggle()
            //not in editing mode drop a ball
        } else {
            if editingMode{
                //creates our box
                let size = CGSize(width: Int.random(in: 16...128), height: 16)
                let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
                box.zRotation = CGFloat.random(in: 0...3)
                box.position = location

                box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                box.physicsBody?.isDynamic = false

                addChild(box)
            } else{
                //create box where that first touch was
                let ball = SKSpriteNode(imageNamed: "ballRed")
                //acts like a ball
                ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
                //bounciness
                ball.physicsBody?.restitution = 0.4
                //collisionbitmask tells us what nodes to hit into
                //contacttestbitmask tells us what collisions we want to look at
                //?? 0 nil coalesin because there may not be a physics body
                ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0

                ball.position = location
                //name the balls so we know theyre balls
                ball.name = "ball"
                addChild(ball)
            }
        }
    }
    
    //makes the bouncers at given position
    func makeBouncer (at position: CGPoint){
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2)
        //makes sure the bouncer doesnt move when hit by something else
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    
    //makes the slots - good and bad depending on the bool
    func makeSlot(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode

        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            //name the slot so we know it's good
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            //name the slot so we know its bad
            slotBase.name = "bad"
        }

        slotBase.position = position
        slotGlow.position = position
        
        //adds physics body to slot base
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        //dont move when hit
        slotBase.physicsBody?.isDynamic = false

        addChild(slotBase)
        addChild(slotGlow)
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    //function to show collisions balls have and to destroy them
    //SKNode is the parent class of SKSpriteKit
    func collisionBetween(ball: SKNode, object: SKNode) {
        if object.name == "good" {
            destroy(ball: ball)
            //update the score
            score += 1
        } else if object.name == "bad" {
            destroy(ball: ball)
            //update the score
            score -= 1
        }
    }
    //function to destory ball
    func destroy(ball: SKNode) {
        //create fire particle 
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = ball.position
            addChild(fireParticles)
        }

        ball.removeFromParent()
    }
    
    //
    func didBegin(_ contact: SKPhysicsContact) {
        
        //ensures bodyA and bodyB have nodes attached to them
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        //if body a is the ball then body a is the ball
        if nodeA.name == "ball" {
            collisionBetween(ball: nodeA, object: nodeB)
        //if body b is the ball then body a is not a ball
        } else if nodeB.name == "ball" {
            collisionBetween(ball: nodeB, object: nodeA)
        }
    }
}
