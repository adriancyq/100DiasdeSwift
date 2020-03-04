//
//  GameScene.swift
//  Project23
//
//  Created by adrian cordova y quiroz on 2/11/20.
//  Copyright © 2020 adrian cordova y quiroz. All rights reserved.
//

import SpriteKit
import GameplayKit
//gives us AV Audio Player
import AVFoundation

//iterates over our bomb creation to get varying groups of enemies
//caseiterable automatically allCases property which lists allCases as an option
enum SequenceType: CaseIterable {
    //enemynot a bomb, maybe a bomb maybe not, two where one is a bomb and 2 are not, random, random, random,random, chain, faster chain
    case oneNoBomb, one, twoWithOneBomb, two, three, four, chain, fastChain
}

//specify what kind of enemy we want
enum ForceBomb {
    case never, always, random
}

class GameScene: SKScene {
    
    //game is running by default
    var isGameEnded = false
    
    //amount of time between enemies being destroyed and popping up
    var popupTime = 0.9
    //stores which enemies are to be created
    var sequence = [SequenceType]()
    //tells us where we are relative to sequence array
    var sequencePosition = 0
    //delay for the chain of enemies
    var chainDelay = 3.0
    //know when all the enemies are destroyed and time to make more
    var nextSequenceQueued = true
    
    var activeSliceBG: SKShapeNode!
    var activeSliceFG: SKShapeNode!
    
    //sound effect for bomb
    var bombSoundEffect: AVAudioPlayer?
    
    //array of sksprite node of active enemies
    var activeEnemies = [SKSpriteNode]()
    
    //array for the users slice points
    var activeSlicePoints = [CGPoint]()
    
    //tracks if the swoosh sound is active
    var isSwooshSoundActive = false
    
    //score keeper
    var gameScore: SKLabelNode!
    var score = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }

    //array of skspritenodes
    var livesImages = [SKSpriteNode]()
    //3 lives for the player
    var lives = 3
    
    
    override func didMove(to view: SKView) {
        //background pic shit
        let background = SKSpriteNode(imageNamed: "sliceBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)

        //sets the gravity of our physics simulation
        physicsWorld.gravity = CGVector(dx: 0, dy: -6)
        //causes all movement to happen slower
        physicsWorld.speed = 0.85

        createScore()
        createLives()
        createSlices()
        
        //make the starting sequence, slow warm up to the game
        sequence = [.oneNoBomb, .oneNoBomb, .twoWithOneBomb, .twoWithOneBomb, .three, .one, .chain]

        //make 1000 random sequences
        for _ in 0 ... 1000 {
            if let nextSequence = SequenceType.allCases.randomElement() {
                sequence.append(nextSequence)
            }
        }

        //toss enemies after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.tossEnemies()
        }
        
    }
    
    //creates the score for us
    func createScore() {
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        addChild(gameScore)

        gameScore.position = CGPoint(x: 8, y: 8)
        score = 0
    }

    //creates the lives count for the players
    func createLives() {
        for i in 0 ..< 3 {
            let spriteNode = SKSpriteNode(imageNamed: "sliceLife")
            spriteNode.position = CGPoint(x: CGFloat(834 + (i * 70)), y: 720)
            addChild(spriteNode)

            livesImages.append(spriteNode)
        }
    }
    
    //make glowing trail of slice mark across screen
    func createSlices() {
        //skshapenode allows you to define any shape you can draw //BG = background
        activeSliceBG = SKShapeNode()
        activeSliceBG.zPosition = 2

        //FG = foreground
        activeSliceFG = SKShapeNode()
        activeSliceFG.zPosition = 3

        //alpha sends it to the foreground
        activeSliceBG.strokeColor = UIColor(red: 1, green: 0.9, blue: 0, alpha: 1)
        activeSliceBG.lineWidth = 9

        activeSliceFG.strokeColor = UIColor.white
        activeSliceFG.lineWidth = 5

        addChild(activeSliceBG)
        addChild(activeSliceFG)
    }
    
    //func for the user's touches moved, where in the scene the user touched
    //add those touches to the array
    //redraw the active slices
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //dont make more enemies if the game is over
        if isGameEnded {
            return
        }
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        //add the users touch location to the array of all the points the users have touched
        activeSlicePoints.append(location)
        redrawActiveSlice()
        
        //if the swoosh sound is not active, then play it
        if !isSwooshSoundActive {
            playSwooshSound()
        }
        
        //tell us all the nodes under their finger
        let nodesAtPoint = nodes(at: location)

        //for all the nodes at the node point
        for case let node as SKSpriteNode in nodesAtPoint {
            if node.name == "enemy" {
                //Create a particle effect over the penguin
                if let emitter = SKEmitterNode(fileNamed: "sliceHitEnemy") {
                    emitter.position = node.position
                    addChild(emitter)
                }

                //Clear its node name so that it can't be swiped repeatedly.
                node.name = ""

                //Disable the isDynamic of its physics body so that it doesn't carry on falling.
                node.physicsBody?.isDynamic = false

                //Make the penguin scale out and fade out at the same time using group
                let scaleOut = SKAction.scale(to: 0.001, duration:0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let group = SKAction.group([scaleOut, fadeOut])

                //After making the penguin scale out and fade out, we should remove it from the scene.
                let seq = SKAction.sequence([group, .removeFromParent()])
                node.run(seq)

                //Add one to the player's score.
                score += 1

                //Remove the enemy from our activeEnemies array.
                if let index = activeEnemies.firstIndex(of: node) {
                    activeEnemies.remove(at: index)
                }

                //Play a sound so the player knows they hit the penguin.
                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
            } else if node.name == "bomb" {
                // destroy bomb
                //must be able to read bomb container as sksprite node
                guard let bombContainer = node.parent as? SKSpriteNode else { continue }

                if let emitter = SKEmitterNode(fileNamed: "sliceHitBomb") {
                    emitter.position = bombContainer.position
                    addChild(emitter)
                }

                //disable physics on the bombContainer
                node.name = ""
                bombContainer.physicsBody?.isDynamic = false

                //scaleout and fadeout the bombs within a group
                let scaleOut = SKAction.scale(to: 0.001, duration:0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let group = SKAction.group([scaleOut, fadeOut])

                let seq = SKAction.sequence([group, .removeFromParent()])
                bombContainer.run(seq)

                //remove the enemies
                if let index = activeEnemies.firstIndex(of: bombContainer) {
                    activeEnemies.remove(at: index)
                }

                //sound
                run(SKAction.playSoundFileNamed("explosion.caf", waitForCompletion: false))
                //call endgame to end it
                endGame(triggeredByBomb: true)
            }
        }
    }
    
    //func for where the user's touches ended
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //fade out after 1/4 of a second
        activeSliceBG.run(SKAction.fadeOut(withDuration: 0.25))
        activeSliceFG.run(SKAction.fadeOut(withDuration: 0.25))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //make sure we have a touch
        guard let touch = touches.first else { return }

        //Remove all existing points in the activeSlicePoints array, because we're starting fresh.
        activeSlicePoints.removeAll(keepingCapacity: true)

        //Get the touch location and add it to the activeSlicePoints array.
        let location = touch.location(in: self)
        activeSlicePoints.append(location)

        //Call the (as yet unwritten) redrawActiveSlice() method to clear the slice shapes.
        redrawActiveSlice()

        //Remove any actions that are currently attached to the slice shapes. This will be important if they are in the middle of a fadeOut(withDuration:) action
        activeSliceBG.removeAllActions()
        activeSliceFG.removeAllActions()

        //Set both slice shapes to have an alpha value of 1 so they are fully visible
        activeSliceBG.alpha = 1
        activeSliceFG.alpha = 1
    }
    
    func redrawActiveSlice() {
        //If we have fewer than two points in our array, we don't have enough data to draw a line so it needs to clear the shapes and exit the method
        if activeSlicePoints.count < 2 {
            activeSliceBG.path = nil
            activeSliceFG.path = nil
            return
        }

        //If we have more than 12 slice points in our array, we need to remove the oldest ones until we have at most 12 – this stops the swipe shapes from becoming too long
        if activeSlicePoints.count > 12 {
            activeSlicePoints.removeFirst(activeSlicePoints.count - 12)
        }

        //It needs to start its line at the position of the first swipe point, then go through each of the others drawing lines to each point
        let path = UIBezierPath()
        path.move(to: activeSlicePoints[0])

        //loop through the activeslicepoints and add that point to our path
        for i in 1 ..< activeSlicePoints.count {
            path.addLine(to: activeSlicePoints[i])
        }

        //Finally, it needs to update the slice shape paths so they get drawn using their designs – i.e., line width and color
        activeSliceBG.path = path.cgPath
        activeSliceFG.path = path.cgPath
    }
    
    func playSwooshSound() {
        //set the swoosh sound to active
        isSwooshSoundActive = true

        //pick any random of our swoosh sounds
        let randomNumber = Int.random(in: 1...3)
        let soundName = "swoosh\(randomNumber).caf"

        //play the random swoosh sound
        let swooshSound = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)

        //make the noise
        run(swooshSound) { [weak self] in
            //set the sound back to false
            self?.isSwooshSoundActive = false
        }
    }
    
    //func to create an enemy - using forceBomb, default is .random
    func createEnemy(forceBomb: ForceBomb = .random) {
        //our enemy sprite node
        let enemy: SKSpriteNode
        
        //make the enemy type a random one
        var enemyType = Int.random(in: 0...6)
        
        //if it shouldnt be a bomb, then dont make it a bomb
        if forceBomb == .never {
            enemyType = 1
            //if it should be a bomb, then definitely make it a bomb
        } else if forceBomb == .always {
            enemyType = 0
        }

        if enemyType == 0 {
            //Create a new SKSpriteNode that will hold the fuse and the bomb image as children, setting its Z position to be 1
            enemy = SKSpriteNode()
            //set in front of everything
            enemy.zPosition = 1
            //name it bombContainer
            enemy.name = "bombContainer"

            //Create the bomb image, name it "bomb", and add it to the container
            let bombImage = SKSpriteNode(imageNamed: "sliceBomb")
            bombImage.name = "bomb"
            enemy.addChild(bombImage)

            //If the bomb fuse sound effect is playing, stop it and destroy it
            if bombSoundEffect != nil {
                bombSoundEffect?.stop()
                bombSoundEffect = nil
            }

            //Create a new bomb fuse sound effect, then play it
            //find the sound file path
            if let path = Bundle.main.url(forResource: "sliceBombFuse", withExtension: "caf") {
                //make a sound out of the file
                if let sound = try?  AVAudioPlayer(contentsOf: path) {
                    bombSoundEffect = sound
                    sound.play()
                }
            }

            //Create a particle emitter node, position it so that it's at the end of the bomb image's fuse, and add it to the container
            if let emitter = SKEmitterNode(fileNamed: "sliceFuse") {
                emitter.position = CGPoint(x: 76, y: 64)
                enemy.addChild(emitter)
            }
            //it's not a bomb
        } else {
            enemy = SKSpriteNode(imageNamed: "penguin")
            run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
            enemy.name = "enemy"
        }

        //Give the enemy a random position off the bottom edge of the screen.
        let randomPosition = CGPoint(x: Int.random(in: 64...960), y: -128)
        enemy.position = randomPosition

        //Create a random angular velocity, which is how fast something should spin
        let randomAngularVelocity = CGFloat.random(in: -3...3 )
        //movemement velocity
        let randomXVelocity: Int

        //Create a random X velocity (how far to move horizontally) that takes into account the enemy's position
        //if it's way too the left, move it to the right fast
        if randomPosition.x < 256 {
            randomXVelocity = Int.random(in: 8...15)
            //if its to the left, move it to the right gently
        } else if randomPosition.x < 512 {
            randomXVelocity = Int.random(in: 3...5)
            //if its to the right, move it to the left gently
        } else if randomPosition.x < 768 {
            randomXVelocity = -Int.random(in: 3...5)
            //it its way to the right, move it to the left fast
        } else {
            randomXVelocity = -Int.random(in: 8...15)
        }

        //Create a random Y velocity just to make things fly at different speeds
        let randomYVelocity = Int.random(in: 24...32)

        //Give all enemies a circular physics body where the collisionBitMask is set to 0 so they don't collide
        //make the radius half the size, 64
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: 64)
        //random speed
        enemy.physicsBody?.velocity = CGVector(dx: randomXVelocity * 40, dy: randomYVelocity * 40)
        //how much it spins
        enemy.physicsBody?.angularVelocity = randomAngularVelocity
        //so they dont collide
        enemy.physicsBody?.collisionBitMask = 0

        //add the current enemy to the array and the game scene
        addChild(enemy)
        activeEnemies.append(enemy)
    }
    
    override func update(_ currentTime: TimeInterval) {
        //if have active enemies
        if activeEnemies.count > 0 {
            //loop thru active enemies in reverse
            for (index, node) in activeEnemies.enumerated().reversed() {
                //if they are below 140
                if node.position.y < -140 {
                    node.removeAllActions()
                    
                    //clear node name if falls under 140
                    if node.name == "enemy" {
                        node.name = ""
                        subtractLife()

                        node.removeFromParent()
                        activeEnemies.remove(at: index)
                        //if the node name is bomb, also remove node name and from screen
                    } else if node.name == "bombContainer" {
                        node.name = ""
                        node.removeFromParent()
                        activeEnemies.remove(at: index)
                    }
                }
            }
            //we dont have enemies
        } else {
            //there is no next sequence
            if !nextSequenceQueued {
                //wait for the popuptime to toss new enemies
                DispatchQueue.main.asyncAfter(deadline: .now() + popupTime) { [weak self] in
                    self?.tossEnemies()
                }
                //set the nextsequencequeued to true so we dont call it again and again and again
                nextSequenceQueued = true
            }
        }
        
        //assume there are no bombs
        var bombCount = 0

        //loop over the whole array of enemies
        for node in activeEnemies {
            //if found a bomb
            if node.name == "bombContainer" {
                //add a bomb to count
                bombCount += 1
                break
            }
        }
        //so there are no bombs
        if bombCount == 0 {
            // no bombs – stop the fuse sound!
            bombSoundEffect?.stop()
            bombSoundEffect = nil
        }
    }
    
    //func to subtract a life when a penguin falls below the screen
    func subtractLife() {
        //sub a life
        lives -= 1
        
        //run the sound
        run(SKAction.playSoundFileNamed("wrong.caf", waitForCompletion: false))

        var life: SKSpriteNode
        
        //2 lives left
        if lives == 2 {
            life = livesImages[0]
            //1 life left
        } else if lives == 1 {
            life = livesImages[1]
            //no lives left
        } else {
            life = livesImages[2]
            endGame(triggeredByBomb: false)
        }

        life.texture = SKTexture(imageNamed: "sliceLifeGone")
        
        //scale it down to show user something has changed
        life.xScale = 1.3
        life.yScale = 1.3
        //scale it to 1 then down in .1 seconds
        life.run(SKAction.scale(to: 1, duration:0.1))
    }
    
    //func to endGame when a bomb is hit
    func endGame(triggeredByBomb: Bool) {
        if isGameEnded {
            return
        }
        //the game is now over
        isGameEnded = true
        //stop everything from moving
        physicsWorld.speed = 0
        //no more swipping
        isUserInteractionEnabled = false

        //stop the sounds
        bombSoundEffect?.stop()
        bombSoundEffect = nil

        //if a bomb ended the game, all 3 images of lives are sliced
        if triggeredByBomb {
            livesImages[0].texture = SKTexture(imageNamed: "sliceLifeGone")
            livesImages[1].texture = SKTexture(imageNamed: "sliceLifeGone")
            livesImages[2].texture = SKTexture(imageNamed: "sliceLifeGone")
        }
    }
    
    //func to toss enemies in the air
    func tossEnemies() {
        //dont make more enemies if the game is over
        if isGameEnded {
            return
        }
        //increase popup time and delay to make it slightly harder
        popupTime *= 0.991
        chainDelay *= 0.99
        //add more gravity in order to make it harder
        physicsWorld.speed *= 1.02

        //read the current sequence position from the sequence array
        let sequenceType = sequence[sequencePosition]

        //all the different cases of the sequence
        switch sequenceType {
            //never force a bomb
        case .oneNoBomb:
            createEnemy(forceBomb: .never)
            //might be a bomb or might not be a bomb
        case .one:
            createEnemy()
            //first enemy cant be a bomb, second must
        case .twoWithOneBomb:
            createEnemy(forceBomb: .never)
            createEnemy(forceBomb: .always)
            //make 2 random
        case .two:
            createEnemy()
            createEnemy()
            //make 3 random
        case .three:
            createEnemy()
            createEnemy()
            createEnemy()
            //make 4 random
        case .four:
            createEnemy()
            createEnemy()
            createEnemy()
            createEnemy()
            //asyncAfter creates enemies after some delay
        case .chain:
            createEnemy()

            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 2)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 3)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 4)) { [weak self] in self?.createEnemy() }
            //asyncAfter creates enemies after a faster delay
        case .fastChain:
            createEnemy()

            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 2)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 3)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 4)) { [weak self] in self?.createEnemy() }
        }
        
        //iterate to the nexst position
        sequencePosition += 1
        //we dont have a call to toss enemies waiting to execute, gets called to true
        //in gap between previous sequence gap and tossEnemies being called
        nextSequenceQueued = false
    }
}
    
    
    
