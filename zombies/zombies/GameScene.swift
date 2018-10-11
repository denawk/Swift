//
//  GameScene.swift
//  zombies
//
//  Created by iD Student on 7/10/17.
//  Copyright © 2017 iD Tech. All rights reserved.
//

import SpriteKit
import GameplayKit

var zombies : [SKSpriteNode] = []
var civilians : [SKSpriteNode] = []
var type : [SKSpriteNode : Int] = [:]
var reload : [SKSpriteNode : Int] = [:]

struct BodyType {
    
    static let None: UInt32 = 0
    static let Zombie: UInt32 = 1
    static let Civilian: UInt32 = 2
    static let Bullet: UInt32 = 4
    
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        
        var x = 0
        while x < 500 {
            x += 1
            addCivilian(location: CGPoint(x: size.width * random() - size.width/2, y: size.height * random() - size.height/2))
        }
        x = 0
        while x < 1 {
            x += 1
            addZombie(location: CGPoint(x: size.width * random() - size.width/2, y: size.height * random() - size.height/2))
        }
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
//        // Get label node from scene and store it for use later
//        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
//        if let label = self.label {
//            label.alpha = 0.0
//            label.run(SKAction.fadeIn(withDuration: 2.0))
//        }
//        
//        // Create shape node to use during mouse interaction
//        let w = (self.size.width + self.size.height) * 0.05
//        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
//        
//        if let spinnyNode = self.spinnyNode {
//            spinnyNode.lineWidth = 2.5
//            
//            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
//            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
//                                              SKAction.fadeOut(withDuration: 0.5),
//                                              SKAction.removeFromParent()]))
        //}
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
        guard let touch = touches.first else { return }
        if touches.count == 2 {
            restartGame()
        } else {
            addZombie(location: touch.location(in: self))
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        for i in zombies {
            let nearest = findNearest(location: i.position, list: civilians)
                if distance(i.position, nearest) >= 200 {
                    i.run(SKAction.move(by: CGVector(dx: (random()*10)-5, dy: (random()*10)-5), duration: 1))
                } else {
                    let xVector = (0 - (i.position.x-nearest.x)*0.02 * random())
                    let yVector = (0 - (i.position.y-nearest.y)*0.02 * random())
                    let vector = CGVector(dx: xVector, dy: yVector)
                    i.run(SKAction.move(by: vector, duration: 1))
                }
            if i.position.x > size.width/2 {
                i.position.x = size.width/2
            }
            if i.position.x < 2 - size.width/2 {
                i.position.x = 2 - size.width/2
            }
            if i.position.y > size.height/2 {
                i.position.y = size.height/2
            }
            if i.position.y < 2 - size.height/2 {
                i.position.y = 2 - size.height/2
            }
            if Int((i.physicsBody?.velocity.dx)!) >= 1 {
                i.physicsBody?.velocity.dx = 1
            }
            if Int((i.physicsBody?.velocity.dy)!) >= 1 {
                i.physicsBody?.velocity.dy = 1
            }
        }
        for i in civilians {
            let nearest = findNearest(location: i.position, list: zombies)
            if type[i] == 2 {
                if distance(nearest, i.position) <= random() * 110 + 60 {
                    if reload[i] == 0 {
                        reload[i] = randomNumber(min: 5, max: 10)
                        addBullet(loc1: i.position, loc2: nearest, accuracy: 10)
                    } else {
                        reload[i] = reload[i]! - 1
                    }
                    let vector = CGVector(dx: (i.position.x-nearest.x)*0.02, dy: (i.position.y-nearest.y)*0.02)
                    i.run(SKAction.move(by: vector, duration: 5))
                } else {
                    i.run(SKAction.move(by: CGVector(dx: (random()*10)-5, dy: (random()*10)-5), duration: 1))
                }
            } else if type[i] == 1 {
                if distance(nearest, i.position) <= random() * 80 + 20 {
                    if reload[i] == 0 {
                        reload[i] = randomNumber(min: 15, max: 45)
                        addBullet(loc1: i.position, loc2: nearest, accuracy: 20)
                    } else {
                        reload[i] = reload[i]! - 1
                    }
                    let vector = CGVector(dx: (i.position.x-nearest.x)*0.01, dy: (i.position.y-nearest.y)*0.01)
                    i.run(SKAction.move(by: vector, duration: 5))
                } else {
                    i.run(SKAction.move(by: CGVector(dx: (random()*10)-5, dy: (random()*10)-5), duration: 1))
                }
            } else if type[i] == 0 {
                if distance(nearest, i.position) <= random() * random() * random() * 240.0 + 45.0 {
                    if i.color == UIColor.blue {

                    } else {
                        let vector = CGVector(dx: (i.position.x-nearest.x)*0.09, dy: (i.position.y-nearest.y)*0.09)
                        i.run(SKAction.move(by: vector, duration: 15))
                    }
                } else {
                    i.run(SKAction.move(by: CGVector(dx: (random()*10)-5, dy: (random()*10)-5), duration: 1))
                }
                print(i.color)
            } else if type[i] == 3 {
                if distance(nearest, i.position) <= random() * 50 + 30 {
                    if reload[i] == 0 {
                        reload[i] = randomNumber(min: 10, max: 30)
                        addBullet(loc1: i.position, loc2: nearest, accuracy: 50)
                        addBullet(loc1: i.position, loc2: nearest, accuracy: 50)
                        addBullet(loc1: i.position, loc2: nearest, accuracy: 50)
                        addBullet(loc1: i.position, loc2: nearest, accuracy: 50)
                        addBullet(loc1: i.position, loc2: nearest, accuracy: 50)
                        addBullet(loc1: i.position, loc2: nearest, accuracy: 50)
                        addBullet(loc1: i.position, loc2: nearest, accuracy: 50)
                    } else {
                        reload[i] = reload[i]! - 1
                    }
                    let vector = CGVector(dx: (i.position.x-nearest.x)*0.01, dy: (i.position.y-nearest.y)*0.01)
                    i.run(SKAction.move(by: vector, duration: 5))
                } else {
                    i.run(SKAction.move(by: CGVector(dx: (random()*10)-5, dy: (random()*10)-5), duration: 1))
                }
            }
            if i.position.x > size.width/2 {
                i.position.x = size.width/2
                i.physicsBody?.velocity.dx = -2
            }
            if i.position.x < 2 - size.width/2 {
                i.position.x = 2 - size.width/2
                i.physicsBody?.velocity.dx = 2
            }
            if i.position.y > size.height/2 {
                i.position.y = size.height/2
                i.physicsBody?.velocity.dy = -2
            }
            if i.position.y < 2 - size.height/2 {
                i.position.y = 2 - size.height/2
                i.physicsBody?.velocity.dy = 2
            }
        }
    }
    
    func addZombie(location : CGPoint) {
        let zombie = SKSpriteNode()
        zombie.color = UIColor.red
        zombie.size = CGSize(width: 5, height: 5)
        zombie.position = location
        
        zombie.physicsBody = SKPhysicsBody(circleOfRadius: zombie.size.width/2)
        zombie.physicsBody?.isDynamic = true
        zombie.physicsBody?.categoryBitMask = BodyType.Zombie
        zombie.physicsBody?.contactTestBitMask = BodyType.Civilian
        zombie.physicsBody?.collisionBitMask = 1
        zombie.physicsBody?.usesPreciseCollisionDetection = true
        
        zombies.append(zombie)
        addChild(zombie)
    }
    
    func addCivilian(location : CGPoint) {
        let civilian = SKSpriteNode()
        civilian.color = UIColor.green
        type[civilian] = 0
        if randomNumber(min: 1, max: 60) == 1 {
            civilian.color = UIColor.blue
            reload[civilian] = 0
            type[civilian] = 1
        }
        if randomNumber(min: 1, max: 150) == 1 {
            civilian.color = UIColor.cyan
            reload[civilian] = 0
            type[civilian] = 2
        }
        if randomNumber(min: 1, max: 150) == 1 {
            civilian.color = UIColor.cyan
            reload[civilian] = 0
            type[civilian] = 3
        }
        civilian.size = CGSize(width: 5, height: 5)
        civilian.position = location
        
        civilian.physicsBody = SKPhysicsBody(circleOfRadius: civilian.size.width/2)
        civilian.physicsBody?.isDynamic = true
        civilian.physicsBody?.categoryBitMask = BodyType.Civilian
        civilian.physicsBody?.contactTestBitMask = BodyType.Zombie
        civilian.physicsBody?.collisionBitMask = 1
        civilian.physicsBody?.usesPreciseCollisionDetection = true
        
        civilians.append(civilian)
        addChild(civilian)
    }
    
    func random() -> CGFloat {
        
        return CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        
    }
    
    func findNearest(location : CGPoint, list : [SKSpriteNode]) -> CGPoint {
        var shortestPoint : CGPoint = CGPoint()
        var shortestDistance = 1000000
        for i in list {
            let x = Int(distance(location, i.position))
            if (x - randomNumber(min: 1, max: 50)) <= shortestDistance {
                shortestDistance = x
                shortestPoint = i.position
            }
        }
        return shortestPoint
    }
    
    func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        let contactA = bodyA.categoryBitMask
        let contactB = bodyB.categoryBitMask
        
        switch contactA {
            
        case BodyType.Zombie:
            
            switch contactB {
                
                
            case BodyType.Zombie:
                
                break
                
                
            case BodyType.Civilian:
                
                if let bodyBNode = contact.bodyB.node as? SKSpriteNode, let bodyANode = contact.bodyA.node as? SKSpriteNode {
                    
                    zombieTouchHuman(zombie: bodyANode, human: bodyBNode)
                    
                }
                
            case BodyType.Bullet:
                
                if let bodyBNode = contact.bodyB.node as? SKSpriteNode, let bodyANode = contact.bodyA.node as? SKSpriteNode {
                    
                    bulletTouchZombie(bullet: bodyBNode, zombie: bodyANode)
                    
                }
                
            default:
                
                break
                
            }
            
            
        case BodyType.Civilian:
            
            
            switch contactB {
                
                
            case BodyType.Zombie:
                
                if let bodyANode = contact.bodyA.node as? SKSpriteNode, let bodyBNode = contact.bodyB.node as? SKSpriteNode {
                    
                    zombieTouchHuman(zombie: bodyBNode, human: bodyANode)
                    
                }
                
                
            case BodyType.Civilian:
                
                break
                
            case BodyType.Bullet:
                
                break
                
            default:
                
                break
                
            }
            
        case BodyType.Bullet:
            
            switch contactB {
                
            case BodyType.Zombie:
                
                if let bodyBNode = contact.bodyB.node as? SKSpriteNode, let bodyANode = contact.bodyA.node as? SKSpriteNode {
                    
                    bulletTouchZombie(bullet: bodyANode, zombie: bodyBNode)
                    
                }
                
            case BodyType.Civilian:
                
                break
                
            case BodyType.Bullet:
                
                break
            
            default:
                
                break
                
            }
            
        default:
            
            break
            
        }
    }
    
    func zombieTouchHuman(zombie : SKSpriteNode, human : SKSpriteNode) {
        addZombie(location: human.position)
        if let index = civilians.index(of: human) {
            civilians.remove(at: index)
        }
        human.removeFromParent()
    }
    func addBullet(loc1 : CGPoint, loc2 : CGPoint, accuracy : Int) {
        let bullet = SKSpriteNode()
        
        let newAccuracy = accuracy * Int(distance(loc1, loc2)/50)
        
        bullet.color = UIColor.yellow
        bullet.size = CGSize(width: 2, height: 2)
        bullet.position = loc1
        let vector = CGVector(dx: (4 * (Int(loc2.x) + randomNumber(min: 0 - newAccuracy, max: newAccuracy) - Int(loc1.x))), dy: (4 * (Int(loc2.y) + randomNumber(min: 0 - newAccuracy, max: newAccuracy) - Int(loc1.y))))
        
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.width/2)
        bullet.physicsBody?.isDynamic = true
        bullet.physicsBody?.categoryBitMask = BodyType.Bullet
        bullet.physicsBody?.contactTestBitMask = BodyType.Zombie
        bullet.physicsBody?.collisionBitMask = 0
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        
        addChild(bullet)
        bullet.run(SKAction.sequence([SKAction.move(by: vector, duration: 1), SKAction.removeFromParent()]))
    }
    
    func bulletTouchZombie(bullet : SKSpriteNode, zombie : SKSpriteNode) {
        zombie.color = UIColor.brown
        zombie.physicsBody?.categoryBitMask = BodyType.None
        zombie.physicsBody?.isDynamic = false
        zombie.removeAllActions()
        bullet.removeFromParent()
        zombies.remove(at: zombies.index(of: zombie)!)
    }
    
    func randomNumber(min : Int, max : Int) -> Int {
        return (Int(arc4random_uniform(UInt32(max - min + 1))) + min)
    }
    
    func restartGame() {
        removeAllChildren()
        zombies = []
        civilians = []
        type = [:]
        reload = [:]
        
        backgroundColor = SKColor.black
        
        var x = 0
        while x < 500 {
            x += 1
            addCivilian(location: CGPoint(x: size.width * random() - size.width/2, y: size.height * random() - size.height/2))
        }
        x = 0
        while x < 1 {
            x += 1
            addZombie(location: CGPoint(x: size.width * random() - size.width/2, y: size.height * random() - size.height/2))
        }
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self

    }
    
}












