//
//  GameScene.swift
//  Project17
//
//  Created by adrian cordova y quiroz on 2/3/20.
//  Copyright © 2020 adrian cordova y quiroz. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //starfield node
    var starfield: SKEmitterNode!
    //player node
    var player: SKSpriteNode!
    
    let possibleEnemies = ["ball", "hammer", "tv"]
    var isGameOver = false
    var gameTimer: Timer?

    //score lable node
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"

        }
    }
    
    override func didMove(to view: SKView) {
        
        //make background color
        backgroundColor = .black

        //new skemitter node with the name of the file
        starfield = SKEmitterNode(fileNamed: "starfield")!
        //position it in the right edge halfway up
        starfield.position = CGPoint(x: 1024, y: 384)
        //prefills starfield by 10 seconds
        starfield.advanceSimulationTime(10)
        //add that node to the display
        addChild(starfield)
        //position it behind the other things in game
        starfield.zPosition = -1

        //player node with image name
        player = SKSpriteNode(imageNamed: "player")
        //position the player
        player.position = CGPoint(x: 100, y: 384)
        //can size and texturize the player
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        //draw around the player based on current size, will collide = 1
        player.physicsBody?.contactTestBitMask = 1
        //add to display
        addChild(player)

        //score label
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)

        score = 0
        
        //disable gravity
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        //create about 3 enemies per second and repeat it
        gameTimer = Timer.scheduledTimer(timeInterval: 0.35, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)

    }
    
    //func to create enemies
    @objc func createEnemy() {
        //create the enemy that is being summoned and make it random part of array
        guard let enemy = possibleEnemies.randomElement() else { return }

        //create a sprite node of type enemy
        let sprite = SKSpriteNode(imageNamed: enemy)
        //place it at the far right in a random Y b/w 50 and 736
        sprite.position = CGPoint(x: 1200, y: Int.random(in: 50...736))
        //add the enemy to the screen
        addChild(sprite)
        
        //give the enemy texture and size
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        //make sure it interacts with other objects
        sprite.physicsBody?.categoryBitMask = 1
        //give it a velocity and have it move left
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        //constant spin of 5
        sprite.physicsBody?.angularVelocity = 5
        //controls how fast things slow down over time. so it never slows down
        sprite.physicsBody?.linearDamping = 0
        //makes it never stop spinning
        sprite.physicsBody?.angularDamping = 0
    }
    
    //remove the nodes from the scene once they are useless (after the player)
    override func update(_ currentTime: TimeInterval) {
        for node in children {
            //any node after -300 kill it
            if node.position.x < -300 {
                node.removeFromParent()
            }
        }
        
        //if the game isnt over keep adding to score
        if !isGameOver {
            score += 1
        }
    }
    
    //called when the players move their fingers on the screen
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //make sure there is a touch
        guard let touch = touches.first else { return }
        //get the location of their finger using location in
        var location = touch.location(in: self)

        //make sure the location is above the score label
        if location.y < 100 {
            location.y = 100
            //make sure the location is below the top of the screen
        } else if location.y > 668 {
            location.y = 668
        }

        //set the player's position
        player.position = location
    }
    
    //end the game when a player hits space debris
    func didBegin(_ contact: SKPhysicsContact) {
        //create the explosion node
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        //set the explosion position to the players position
        explosion.position = player.position
        //add to display
        addChild(explosion)
        
        player.removeFromParent()

        isGameOver = true
    }
}
