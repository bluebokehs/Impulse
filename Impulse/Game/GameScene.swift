//
//  GameScene.swift
//  Impulse
//
//  Created by Owen Kern on 11/16/18.
//  Copyright © 2018 Owen Kern. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player:SKSpriteNode!
    var scoreLabel:SKLabelNode!
    var score:Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var gameTimer:Timer!
    let bossCategory:UInt32     = 0x1 << 2
    let torpedoCategory:UInt32  = 0x1 << 3
    let enemyCategory:UInt32    = 0x1 << 2
    let obstacleCategory:UInt32 = 0x1 << 1
    let playerCategory:UInt32   = 0x1 << 0
    
    var livesArray:[SKSpriteNode]!
//    var torpedoArray:[SKSpriteNode]!
    
    let motionManager = CMMotionManager()
    var xAcceleration:CGFloat = 0
    
    var seconds = 0
    
    var torpedoLabel:SKLabelNode!
    var torpedoCount:Int = 0 {
        didSet {
            torpedoLabel.text = "Torpedos: \(torpedoCount)"
        }
    }
    
    var timer = Timer()
    
    @objc override func didMove(to view: SKView) {
        
        addLives()
        
        // Player Styling
        player = SKSpriteNode(imageNamed: "Player")
        player.position = CGPoint(x: 0, y: (-self.frame.size.height / 2) * (3/5))
        player.scale(to: CGSize(width: player.size.width * 2.25, height: player.size.height * 2.25))
        
        // Player Physics
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.categoryBitMask = playerCategory
        player.physicsBody?.contactTestBitMask = obstacleCategory
        player.physicsBody?.collisionBitMask = 0
        player.physicsBody?.usesPreciseCollisionDetection = true
        self.addChild(player)
        
        // Physics
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        // Score Styling
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: -self.frame.size.width / 3, y: self.frame.size.height / 2 * (5/6))
        scoreLabel.fontName = "Avenir-Heavy"
        scoreLabel.fontSize = 36
        scoreLabel.fontColor = UIColor.white
        score = 0
        self.addChild(scoreLabel)
        
        // TorpedoCount Styling
        torpedoLabel = SKLabelNode(text: "Torpedos: 0")
        torpedoLabel.position = CGPoint(x: -self.frame.size.width / 3, y: self.frame.size.height / 2 * (4/6))
        torpedoLabel.fontName = "Avenir-Heavy"
        torpedoLabel.fontSize = 36
        torpedoLabel.fontColor = UIColor.white
        self.addChild(torpedoLabel)
        
        let obstacleInterval = 1.00
        
        let enemyInterval = 2.50
        
        
        
        //adds new obstacles every obstacleInterval seconds
        gameTimer = Timer.scheduledTimer(timeInterval: TimeInterval(obstacleInterval), target: self, selector: #selector(addObstacle), userInfo: nil, repeats: true)
        
        //adds new enemies every enemyInterval seconds
        gameTimer = Timer.scheduledTimer(timeInterval: TimeInterval(enemyInterval), target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data:CMAccelerometerData?, error:Error?) in
            if let accelerometerData = data {
                let acceleration = accelerometerData.acceleration
                self.xAcceleration = CGFloat(acceleration.x) * 0.75 + self.xAcceleration * 0.25
            }
        }
        
    }
    
    @objc func updateTimer () {
        seconds += 1
        score = seconds
        
        if score % 10 == 0{
            addBoss()
        } else {
            addEnemy()
        }
        
    }
    
    //adds bosses
    func addBoss() {
        let boss = SKSpriteNode(imageNamed: "Boss")
        boss.position = CGPoint(x: 0, y: self.frame.size.height + boss.size.height)
        boss.scale(to: CGSize(width: boss.size.width * 2, height: boss.size.height * 2))
        
        boss.physicsBody = SKPhysicsBody(rectangleOf: boss.size)
        boss.physicsBody?.isDynamic = true
        
        boss.physicsBody?.categoryBitMask = bossCategory
        boss.physicsBody?.contactTestBitMask = playerCategory
        boss.physicsBody?.collisionBitMask = 0
        
        self.addChild(boss)
        
        let animationDuration:TimeInterval = 6
        
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x: 0, y: -self.frame.size.height/2 - self.frame.size.height/5), duration: animationDuration))
        
        actionArray.append(SKAction.run {
            if self.livesArray.count > 0 {
                let liveNode = self.livesArray.first
                liveNode!.removeFromParent()
                self.livesArray.removeFirst()
                
                if self.livesArray.count == 0 {
                    //Game Over Screen Transition
                    let transition = SKTransition.fade(withDuration: 0.5)
                    let gameOver = SKScene(fileNamed: "GameOverScene") as? GameOverScene
                    gameOver?.score = self.score
                    gameOver?.scaleMode = .aspectFill
                    self.view?.presentScene(gameOver!, transition: transition)
                }
            }
        })
        
        actionArray.append(SKAction.removeFromParent())
        
        boss.run(SKAction.sequence(actionArray))
    }
    
    //adds new obstacles
    @objc func addObstacle () {
        let obstacle = SKSpriteNode(imageNamed: "Rectangle")
        let randomObstaclePosition = GKRandomDistribution(lowestValue: Int(-self.frame.size.width / 2), highestValue: Int(self.frame.size.width / 2))
        let position = CGFloat(randomObstaclePosition.nextInt())
        
        obstacle.position = CGPoint(x: position, y: self.frame.size.height + obstacle.size.height)
        obstacle.scale(to: CGSize(width: obstacle.size.width * 2, height: obstacle.size.height * 2))
        
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: obstacle.size)
        obstacle.physicsBody?.isDynamic = true
        
        obstacle.physicsBody?.categoryBitMask = obstacleCategory
        obstacle.physicsBody?.contactTestBitMask = playerCategory
        obstacle.physicsBody?.collisionBitMask = 0
        
        self.addChild(obstacle)
    
        let animationDuration:TimeInterval = 6
 
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x: position, y: -self.frame.size.height/2 - self.frame.size.height/5), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        
        obstacle.run(SKAction.sequence(actionArray))
        
    }
    
    @objc func addEnemy () {
        let enemy = SKSpriteNode(imageNamed: "Enemy")
        let randomEnemyPosition = GKRandomDistribution(lowestValue: Int((-self.frame.size.width / 2) + 100), highestValue: Int((self.frame.size.width / 2) - 100))
        let position = CGFloat(randomEnemyPosition.nextInt())
        
        enemy.position = CGPoint(x: position, y: self.frame.size.height + enemy.size.height)
        enemy.scale(to: CGSize(width: enemy.size.width * 2, height: enemy.size.height * 2))
        
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody?.isDynamic = true
        
        enemy.physicsBody?.categoryBitMask = enemyCategory
        enemy.physicsBody?.contactTestBitMask = playerCategory
        enemy.physicsBody?.collisionBitMask = 0
        
        self.addChild(enemy)
        
        let animationDuration:TimeInterval = 6
        
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x: position, y: -self.frame.size.height/2 - self.frame.size.height/5), duration: animationDuration))
        
        actionArray.append(SKAction.run {
            if self.livesArray.count > 0 {
                let liveNode = self.livesArray.first
                liveNode!.removeFromParent()
                self.livesArray.removeFirst()
                
                if self.livesArray.count == 0 {
                    //Game Over Screen Transition
                    let transition = SKTransition.fade(withDuration: 0.5)
                    let gameOver = SKScene(fileNamed: "GameOverScene") as? GameOverScene
                    gameOver?.score = self.score
                    gameOver?.scaleMode = .aspectFill
                    self.view?.presentScene(gameOver!, transition: transition)
                }
            }
        })
        
        actionArray.append(SKAction.removeFromParent())
        
        enemy.run(SKAction.sequence(actionArray))
    }
    
    //adds 3 lives at beginning of game
    func addLives() {
        livesArray = [SKSpriteNode]()
        
        for live in 1 ... 3 {
            let liveNode = SKSpriteNode(imageNamed: "Player")
            liveNode.position = CGPoint(x: self.frame.size.width/2 - CGFloat(4 - live) * (liveNode.size.width * 2), y: self.frame.size.height/2 * (5/6))
            liveNode.scale(to: CGSize(width: liveNode.size.width * 2, height: liveNode.size.height * 2))
            self.addChild(liveNode)
            livesArray.append(liveNode)
        }
    }
    
//    func addTorpedos() {
//        torpedoArray = [SKSpriteNode]()
//
//        for torpedo in 1 ... 5 {
//            let torpedoNode = SKSpriteNode(imageNamed: "torpedo")
//            torpedoNode.position = CGPoint(x: self.frame.size.width/2 - CGFloat(6 - torpedo) * (torpedoNode.size.width * 2), y: self.frame.size.height/2 * (5/6))
//            torpedoNode.scale(to: CGSize(width: torpedoNode.size.width * 2, height: torpedoNode.size.height * 2))
//            self.addChild(torpedoNode)
//            torpedoArray.append(torpedoNode)
//        }
//    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        fireTorpedo()
    }
    
    func fireTorpedo () {
        
        // limit of torpedos on screen
        let limit = 5
        
        // if under the limit, shoot a torpedo
        if torpedoCount < limit {
            torpedoCount += 1
            
            self.run(SKAction.playSoundFileNamed("Pop.mp3", waitForCompletion: false))
            
            let torpedoNode = SKSpriteNode(imageNamed: "torpedo")
            torpedoNode.position = player.position
            torpedoNode.position.y += 20
            torpedoNode.scale(to: CGSize(width: torpedoNode.size.width * 2.5, height: torpedoNode.size.height * 2.5))
            
            torpedoNode.physicsBody = SKPhysicsBody(circleOfRadius: torpedoNode.size.width / 2)
            torpedoNode.physicsBody?.isDynamic = true
            
            torpedoNode.physicsBody?.categoryBitMask = torpedoCategory
            torpedoNode.physicsBody?.contactTestBitMask = enemyCategory
            torpedoNode.physicsBody?.collisionBitMask = 0
            torpedoNode.physicsBody?.usesPreciseCollisionDetection = true
            
            self.addChild(torpedoNode)
            
            let animationDuration:TimeInterval = 5
            
            var actionArray = [SKAction]()
            
            actionArray.append(SKAction.move(to: CGPoint(x: player.position.x, y: self.frame.size.height/2 + torpedoNode.size.height), duration: animationDuration))
            
//            actionArray.append(SKAction.run {
//                if self.torpedoArray.count > 0 {
//                    let torpedoNode = self.torpedoArray.first
//                    torpedoNode!.removeFromParent()
//                    self.torpedoArray.removeFirst()
//
//                    if self.torpedoArray.count == 0 {
//
//                    }
//                }
//            })
            
            actionArray.append(SKAction.removeFromParent())
            
            //remove torpedoCount if goes off of screen
            torpedoNode.run(SKAction.sequence(actionArray)) {
                self.torpedoCount -= 1
            }
        }
    }
    
    //collisions
    func didBegin(_ contact: SKPhysicsContact) {
        let collision:UInt32 = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        // if the player hits an obstacle
        if collision == playerCategory | obstacleCategory {
            let explosion = SKEmitterNode(fileNamed: "Explode")!
            explosion.position = player.position
            self.addChild(explosion)
            self.run(SKAction.playSoundFileNamed("Pulse.mp3", waitForCompletion: false))
            
            self.run(SKAction.wait(forDuration: 2)) {
                explosion.removeFromParent()
            }
        }
        
        // if the player hits an enemy
        if collision == playerCategory | enemyCategory {
            let explosion = SKEmitterNode(fileNamed: "Explode")!
            explosion.position = player.position
            self.addChild(explosion)
            self.run(SKAction.playSoundFileNamed("Pulse.mp3", waitForCompletion: false))
            
            self.run(SKAction.wait(forDuration: 2)) {
                explosion.removeFromParent()
            }
        }
        
        // if the player hits an boss
        if collision == playerCategory | bossCategory {
            let explosion = SKEmitterNode(fileNamed: "Explode")!
            explosion.position = player.position
            self.addChild(explosion)
            self.run(SKAction.playSoundFileNamed("Pulse.mp3", waitForCompletion: false))
            
            self.run(SKAction.wait(forDuration: 2)) {
                explosion.removeFromParent()
            }
            print("player hit")
        }
        
        // if torpedo hits an enemy
        if collision == torpedoCategory | enemyCategory {
            let explosion = SKEmitterNode(fileNamed: "Explode")!
            explosion.position = contact.bodyB.node!.position
            self.addChild(explosion)
            self.run(SKAction.playSoundFileNamed("Pulse.mp3", waitForCompletion: false))
            
            contact.bodyA.node?.removeFromParent()
            contact.bodyB.node?.removeFromParent()
            
            self.run(SKAction.wait(forDuration: 2)) {
                explosion.removeFromParent()
            }
            
            torpedoCount -= 1
        }
        
        // if torpedo hits a boss
        if collision == torpedoCategory | bossCategory {
            let explosion = SKEmitterNode(fileNamed: "Explode")!
            explosion.position = contact.bodyB.node!.position
            self.addChild(explosion)
            self.run(SKAction.playSoundFileNamed("Pulse.mp3", waitForCompletion: false))
            
            contact.bodyA.node?.removeFromParent()
            contact.bodyB.node?.removeFromParent()
            
            self.run(SKAction.wait(forDuration: 2)) {
                explosion.removeFromParent()
            }
            print("hit")
            torpedoCount -= 1
        }
        
        
    }
    
    // player moving from one side of the screen to the other
    override func didSimulatePhysics() {
        player.position.x += xAcceleration * 75
        
        if player.position.x < -self.frame.width/2 {
            player.position = CGPoint(x: self.size.width/2 - 20, y: player.position.y)
        }else if player.position.x > self.size.width/2 - 20 {
            player.position = CGPoint(x: -self.frame.width/2 + 20, y: player.position.y)
        }
        
    }
}

