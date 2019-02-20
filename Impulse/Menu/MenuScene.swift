//
//  MenuScene.swift
//  Impulse
//
//  Created by Owen Kern on 11/30/18.
//  Copyright © 2018 Owen Kern. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
    
    var newGameButtonNode:SKSpriteNode!
    var newFlyerButtonNode:SKSpriteNode!
    
    override func didMove(to view: SKView) {
        
        newGameButtonNode = (self.childNode(withName: "newGameButton") as! SKSpriteNode)
        
        newGameButtonNode.texture = SKTexture(imageNamed: "playButton")
        newGameButtonNode.position = CGPoint(x: 0, y: (-self.frame.size.height / 7))
        newGameButtonNode.scale(to: CGSize(width: newGameButtonNode.size.width * 1.5, height: newGameButtonNode.size.height * 1.5))
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first
        
        if let location = touch?.location(in: self) {
            let nodesArray = self.nodes(at: location)
            
            if nodesArray.first?.name == "newGameButton" {
                let transition = SKTransition.fade(withDuration: 0.5)
                let gameScene = GameScene(fileNamed: "GameScene")
                gameScene?.scaleMode = .aspectFill
                self.view?.presentScene(gameScene!, transition: transition)
            }
        }
    }
    
}
