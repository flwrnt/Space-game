//
//  GameScene.swift
//  Space
//
//  Created by Florent Auplat on 18/12/2014.
//  Copyright (c) 2014 Flwrnt. All rights reserved.
//

import SpriteKit

var niveau = 1

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player = SKSpriteNode()
    var lastYieldTimeInterval = NSTimeInterval()
    var lastUpdateLastInteval = NSTimeInterval()
    var alienDestroy = 0
    
    
    var scoreLabel = SKLabelNode()
    
    let alienCategory: UInt32 = 0x1 << 1
    let photonCategory: UInt32 = 0x1 << 0
    
    override func didMoveToView(view: SKView) {
        
    }
    
    override init(size: CGSize){
        super.init(size: size)
        self.backgroundColor = SKColor.blackColor()
        
        self.physicsWorld.gravity = CGVectorMake(0,0)
        self.physicsWorld.contactDelegate = self
        
        player = SKSpriteNode(imageNamed: "shuttle")
        player.position = CGPointMake(self.frame.size.width / 2, player.size.height / 2 + 20)
        
        scoreLabel = SKLabelNode(fontNamed: "Avenir-Light")
        scoreLabel.text = "Score : " + String(alienDestroy)
        scoreLabel.fontSize = 20
        scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) * 1.7)
        self.addChild(scoreLabel)
        
        self.addChild(player)
    }
    
    func addAlien(){
        var alien = SKSpriteNode(imageNamed: "alien")
        alien.physicsBody = SKPhysicsBody(rectangleOfSize: alien.size)
        alien.physicsBody?.dynamic = true
        alien.physicsBody?.categoryBitMask = alienCategory
        alien.physicsBody?.contactTestBitMask = photonCategory
        alien.physicsBody?.collisionBitMask = 0
        
        let minXpos = alien.size.width / 2
        let maxXpos = self.frame.size.width - alien.size.width / 2
        let rangeX = maxXpos - minXpos
        let position: CGFloat = CGFloat(arc4random()) % CGFloat(rangeX) + CGFloat(minXpos)
        
        alien.position = CGPointMake(position, self.frame.size.height + alien.size.height)
        
        self.addChild(alien)
        
        let minDuration = 2
        let maxDuration = 4
        let rangeDuration = maxDuration - minDuration
        let duration = Int(arc4random()) % Int(rangeDuration) + Int(minDuration)
        
        var actionArray = NSMutableArray()
        
        actionArray.addObject(SKAction.moveTo(CGPointMake(position, -alien.size.height), duration: NSTimeInterval(duration)))
        actionArray.addObject(SKAction.runBlock({
            var transition = SKTransition.flipHorizontalWithDuration(0.5)
            var gameOverScence = GameOverScene(size: self.size, won: false, level: 0)
            self.view?.presentScene(gameOverScence)
        }))
        alien.runAction(SKAction.sequence(actionArray as [AnyObject]))
        
        SKAction.removeFromParent()
    }
    
    func updateWithTimeSinceLastUpdate(timeSinceLastUpdate: CFTimeInterval){
        lastYieldTimeInterval += timeSinceLastUpdate
        
        if (lastYieldTimeInterval > 1){
            lastYieldTimeInterval = 0
            addAlien()
        }
    }
    
    func vecAdd(a: CGPoint, b: CGPoint) -> CGPoint {
        return CGPointMake(a.x + b.x, a.y + b.y)
    }
    
    func vecSub(a: CGPoint, b: CGPoint) -> CGPoint {
        return CGPointMake(a.x - b.x, a.y - b.y)
    }
    
    func vecMult(a: CGPoint, b: CGFloat) -> CGPoint {
        return CGPointMake(a.x * b, a.y * b)
    }
    
    func vecLength(a: CGPoint) -> CGFloat {
        return CGFloat(sqrt(CFloat(a.x) * CFloat(a.x) + CFloat(a.y) * CFloat(a.y)))
    }
    
    func vecNormalize(a: CGPoint) -> CGPoint {
        var length = vecLength(a)
        return CGPointMake(a.x / length, a.y / length)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.runAction(SKAction.playSoundFileNamed( "torpedo.mp3", waitForCompletion: false))
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            var torpedo = SKSpriteNode(imageNamed: "torpedo")
            torpedo.position = player.position
            
            torpedo.physicsBody = SKPhysicsBody(circleOfRadius: torpedo.size.width / 2)
            torpedo.physicsBody?.dynamic = true
            torpedo.physicsBody?.categoryBitMask = photonCategory
            torpedo.physicsBody?.contactTestBitMask = alienCategory
            torpedo.physicsBody?.collisionBitMask = 0
            torpedo.physicsBody?.usesPreciseCollisionDetection = true
            
            var offset = vecSub(location, b: torpedo.position)
            
            if (offset.y < 0){
                return
            }
            
            self.addChild(torpedo)
            
            var direction = vecNormalize(offset)
            var shotLength = vecMult(direction, b: 1000)
            var finalDestination = vecAdd(shotLength, b: torpedo.position)
            
            let velocity = 568/1
            let moveDuration = Float(self.size.width) / Float(velocity)
            
            var actionArray = NSMutableArray()
            actionArray.addObject(SKAction.moveTo(finalDestination, duration: NSTimeInterval(moveDuration)))
            actionArray.addObject(SKAction.removeFromParent())
            torpedo.runAction(SKAction.sequence(actionArray as [AnyObject]))
        }
    }
    
    
    func torpedoDidCollideWithAlien(torpedo: SKSpriteNode, alien: SKSpriteNode){
        torpedo.removeFromParent()
        alien.removeFromParent()
        
        alienDestroy++
        
        if (niveau == 1){

            if (alienDestroy > 5){
                //var transition = SKTransition.flipHorizontalWithDuration(0.5)
                //var gameOverScence = GameOverScene(size: self.size, won: true)
                //self.view?.presentScene(gameOverScence)
            
                self.runAction(SKAction.sequence([SKAction.waitForDuration(0),
                    SKAction.runBlock({
                        var transition = SKTransition.flipHorizontalWithDuration(0.5)
                        var gameOverScence = GameOverScene(size: self.size, won: true, level: 1)
                        self.view?.presentScene(gameOverScence, transition: transition)
                    })]))
                
                niveau++
            }
        }
        
        if (niveau == 2){
            
            if (alienDestroy > 10){
                
                self.runAction(SKAction.sequence([SKAction.waitForDuration(0),
                    SKAction.runBlock({
                        var transition = SKTransition.flipHorizontalWithDuration(0.5)
                        var gameOverScence = GameOverScene(size: self.size, won: true, level: 2)
                        self.view?.presentScene(gameOverScence, transition: transition)
                    })]))
                
                niveau++
            }
        }
        
        if (niveau == 3){
            
            if (alienDestroy > 20){
                
                self.runAction(SKAction.sequence([SKAction.waitForDuration(0),
                    SKAction.runBlock({
                        var transition = SKTransition.flipHorizontalWithDuration(0.5)
                        var gameOverScence = GameOverScene(size: self.size, won: true, level: 3)
                        self.view?.presentScene(gameOverScence, transition: transition)
                    })]))
                
                niveau++
            }
        }
        
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        
        if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if ((firstBody.categoryBitMask & photonCategory != 0) && (secondBody.categoryBitMask & alienCategory != 0)){
            torpedoDidCollideWithAlien(firstBody.node as! SKSpriteNode, alien: secondBody.node as! SKSpriteNode)
            
            scoreLabel.text = "Score : " + String(alienDestroy)
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        var timeSinceLastUpdate = currentTime - lastUpdateLastInteval
         lastUpdateLastInteval = currentTime
        
        if (timeSinceLastUpdate > 1){
            timeSinceLastUpdate = 1/60
            lastUpdateLastInteval = currentTime
        }
        updateWithTimeSinceLastUpdate(timeSinceLastUpdate)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
