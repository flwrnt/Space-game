//
//  GameOverScene.swift
//  Space
//
//  Created by Florent Auplat on 18/12/2014.
//  Copyright (c) 2014 Flwrnt. All rights reserved.
//

import UIKit
import SpriteKit

class GameOverScene: SKScene {
    
    init(size: CGSize, won: Bool, level: Int){
        super.init(size: size)
        
        self.backgroundColor = UIColor.blackColor()
        
        var message = ""
        var msgLevel = ""
        
        if (won){
            message = "You Win !"
            if (level == 1){
                msgLevel = "Level 2"
            }
            if (level == 2){
                msgLevel = "Level 3"
            }
            if (level == 3){
                msgLevel = "No more level.."
            }
        }
        else{
            message = "Game Over !"
            msgLevel = "Go back to level 1.."
        }
        
        var messageLabel = SKLabelNode(fontNamed: "Avenir-Light")
        messageLabel.text = message
        messageLabel.fontColor = SKColor.whiteColor()
        messageLabel.position = CGPointMake(self.size.width/2, self.size.height/2)
        
        var msgLevelLabel = SKLabelNode(fontNamed: "Avenir-Light")
        msgLevelLabel.text = msgLevel
        msgLevelLabel.fontColor = SKColor.whiteColor()
        msgLevelLabel.position = CGPointMake(self.size.width/2, self.size.height/2 - 100)
        
        self.addChild(msgLevelLabel)
        self.addChild(messageLabel)
        
        self.runAction(SKAction.sequence([SKAction.waitForDuration(3.0),
            SKAction.runBlock({
                var transition = SKTransition.flipHorizontalWithDuration(0.5)
                var scene = GameScene(size: self.size)
                self.view?.presentScene(scene, transition: transition)
            })]))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
