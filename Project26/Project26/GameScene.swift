//
//  GameScene.swift
//  Project26
//
//  Created by adrian cordova y quiroz on 2/23/20.
//  Copyright © 2020 adrian cordova y quiroz. All rights reserved.
//

import CoreMotion
import SpriteKit
import GameplayKit

//how to decide where the player is
//and what collisions have happened
enum CollisionTypes: UInt32 {
    case player = 1
    case wall = 2
    case star = 4
    case vortex = 8
    case finish = 16
}

class GameScene: SKScene,SKPhysicsContactDelegate {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    //this is the players sprite node
    var player: SKSpriteNode!
    //gets the users last touch position
    var lastTouchPosition: CGPoint?
    //holds data collected for motion
    var motionManager: CMMotionManager!
    var isGameOver = false
    
    //score keeper and label
    var scoreLabel: SKLabelNode!

    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        //create our background m8
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        loadLevel()
        createPlayer()
        
        //no gravity
        physicsWorld.gravity = .zero
        //tell us when a collision happens
        physicsWorld.contactDelegate = self
        
        //make motion manager
        motionManager = CMMotionManager()
        //start collecting the motion data
        motionManager.startAccelerometerUpdates()
        
        //score lable shit
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.zPosition = 2
        addChild(scoreLabel)
        
    }
    
    //func to see when collisions began
    func didBegin(_ contact: SKPhysicsContact) {
        //pull out the 2 nodes that collided
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }

        //if the nodea is a player
        if nodeA == player {
            //then player collided with someone else
            playerCollided(with: nodeB)
        //if the player is node b
        } else if nodeB == player {
            //they hit nodeA
            playerCollided(with: nodeA)
        }
    }
    
    //function to create the player
    func createPlayer() {
        //set it to the player image
        player = SKSpriteNode(imageNamed: "player")
        //drop in starting position
        player.position = CGPoint(x: 96, y: 672)
        //set to the front
        player.zPosition = 1
        //make it half the size of the node
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        //make sure it doesnt rotate
        player.physicsBody?.allowsRotation = false
        //applies friction to it's movement
        player.physicsBody?.linearDamping = 0.5

        //set it to the player bitmask
        player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        //create it's bitmask of player, star, finish, and wall to know when it has hit all those
        //| means combines previous number with current number - adds them together
        player.physicsBody?.contactTestBitMask = CollisionTypes.star.rawValue | CollisionTypes.vortex.rawValue | CollisionTypes.finish.rawValue
        player.physicsBody?.collisionBitMask = CollisionTypes.wall.rawValue
        //add this homie to the game scene
        addChild(player)
    }
    
    //loads the level for us and creating SpriteKit nodes onscreen
    func loadLevel() {
        //find the url in our bundle for the level1txt file
        guard let levelURL = Bundle.main.url(forResource: "level1", withExtension: "txt") else {
            fatalError("Could not find level1.txt in the app bundle.")
        }
        //load the string content of that file into a string
        guard let levelString = try? String(contentsOf: levelURL) else {
            fatalError("Could not load level1.txt from the app bundle.")
        }

        //split the string into lines
        let lines = levelString.components(separatedBy: "\n")

        //loop over all the rows in reverse
        for (row, line) in lines.reversed().enumerated() {
            //loop over all the columns
            for (column, letter) in line.enumerated() {
                //make the position for the tile
                let position = CGPoint(x: (64 * column) + 32, y: (64 * row) + 32)

                //decide which set of spritekit will be created according to the letter
                if letter == "x" {
                    // load wall
                    let node = SKSpriteNode(imageNamed: "block")
                    //set the block at the position we calculated
                    node.position = position

                    //create the sk physics body
                    node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
                    //get the enum value for a wall
                    node.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue
                    node.physicsBody?.isDynamic = false
                    addChild(node)
                } else if letter == "v"  {
                    // load vortex
                    let node = SKSpriteNode(imageNamed: "vortex")
                    node.name = "vortex"
                    node.position = position
                    //rotate by 180 degs every 1 second
                    node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
                    //half the size of the node
                    node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
                    node.physicsBody?.isDynamic = false

                    node.physicsBody?.categoryBitMask = CollisionTypes.vortex.rawValue
                    node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
                    //bounces off of nothing
                    node.physicsBody?.collisionBitMask = 0
                    addChild(node)
                } else if letter == "s"  {
                    // load star
                    let node = SKSpriteNode(imageNamed: "star")
                    node.name = "star"
                    //make it half the size of the node
                    node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
                    //dont move around
                    node.physicsBody?.isDynamic = false

                    //get the star category bit mask
                    node.physicsBody?.categoryBitMask = CollisionTypes.star.rawValue
                    //tell us when the player touches it
                    node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
                    //bounce off of nothing
                    node.physicsBody?.collisionBitMask = 0
                    node.position = position
                    addChild(node)
                } else if letter == "f"  {
                    // load finish
                    let node = SKSpriteNode(imageNamed: "finish")
                    node.name = "finish"
                    node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
                    node.physicsBody?.isDynamic = false

                    node.physicsBody?.categoryBitMask = CollisionTypes.finish.rawValue
                    node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
                    node.physicsBody?.collisionBitMask = 0
                    node.position = position
                    addChild(node)
                } else if letter == " " {
                    // this is an empty space – do nothing!
                } else {
                    //forces code to crash if reaches here
                    fatalError("Unknown level letter: \(letter)")
                }
            }
        }
    }
    
    //decides what type of collision the player hit
    func playerCollided(with node: SKNode) {
        //player hit a vortex
        if node.name == "vortex" {
            //stop the player from moving
            player.physicsBody?.isDynamic = false
            //end the game
            isGameOver = true
            //remove 1 from their score
            score -= 1

            //move the ball over the vortex
            let move = SKAction.move(to: node.position, duration: 0.25)
            //suck the ball into the vortex
            let scale = SKAction.scale(to: 0.0001, duration: 0.25)
            //remove the player from the screen
            let remove = SKAction.removeFromParent()
            //the dying sequence
            let sequence = SKAction.sequence([move, scale, remove])

            //run the dying sequence
            player.run(sequence) { [weak self] in
                //create a new player
                self?.createPlayer()
                //the game is on again
                self?.isGameOver = false
            }
        //if they hit a star, remove it and add a point
        } else if node.name == "star" {
            node.removeFromParent()
            score += 1
        //if they hit the finish then load the next level
        } else if node.name == "finish" {
            // next level?
        }
    }
    
    //get when the user started touching the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchPosition = location
    }

    //get the touches moved once touched the screen
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchPosition = location
    }
    //get the users last touch on the screen
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchPosition = nil
    }
    //update the game scene
    override func update(_ currentTime: TimeInterval) {
        //if the game is over then get outta here
        guard isGameOver == false else { return }
    //tells this to run only if in simulator
    #if targetEnvironment(simulator)
        if let currentTouch = lastTouchPosition {
            //gets the difference of the currenttouch - the players previous position
            //divide by 100 take make the value much smaller
            let diff = CGPoint(x: currentTouch.x - player.position.x, y: currentTouch.y - player.position.y)
            physicsWorld.gravity = CGVector(dx: diff.x / 100, dy: diff.y / 100)
        }
    //run this code when not in simulator, for tilt info on live device
    #else
        if let accelerometerData = motionManager.accelerometerData {
            //flip coordinates since the device has been set to right landscape only
            //* 50 to make the vectors smallers so its not so hard to rotate
            physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * 50)
        }
    #endif
    }
}
