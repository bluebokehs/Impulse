//
//  GameOverScene.swift
//  Impulse
//
//  Created by Owen Kern on 12/29/18.
//  Copyright © 2018 Owen Kern. All rights reserved.
//

import UIKit
import SpriteKit

class GameOverScene: SKScene {
    
    var score:Int = 0
    
    var scoreLabel:SKLabelNode!
    var menuButtonNode:SKSpriteNode!
    
    override func didMove(to view: SKView) {
        scoreLabel = self.childNode(withName: "scoreLabel") as? SKLabelNode
        scoreLabel.text = "\(score)"
        
        menuButtonNode = self.childNode(withName: "menuButton") as? SKSpriteNode
        menuButtonNode.texture = SKTexture(imageNamed: "menuButton")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if let location = touch?.location(in: self) {
            let node = self.nodes(at: location)
            
            if node[0].name == "menuButton" {
                let transition = SKTransition.fade(withDuration: 0.5)
                let menuScene = MenuScene(fileNamed: "MenuScene")
                menuScene?.scaleMode = .aspectFill
                self.view?.presentScene(menuScene!, transition: transition)
            }
        }
    }
    
    
    

    
}
