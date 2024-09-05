//
//  GameScene.swift
//  Asteroids
//
//  Created by Conner Yoon on 8/22/24.
//

import SpriteKit

class GameScene: SKScene {
   //MARK: Properties
    private var left : SKSpriteNode?
    private var right : SKSpriteNode?
    private var hyper : SKSpriteNode?
    private var thrust : SKSpriteNode?
    private var fire : SKSpriteNode?
    private var back : SKSpriteNode?
    
    //Player Prop
    let player = SKSpriteNode(imageNamed: "ship-still")
    var isPlayerAlive = false
    var isRotatingLeft = false
    var isRotatingRight = false
    var isThrustOn = false
    var isBacking = false
    var isHyperSpacing = false
    
    //Controls
    var rotation : CGFloat = 0 {
        didSet{//changes when update
            player.zRotation = deg2rad(degrees: rotation)
        }
    }
    let rotationFactor : CGFloat = 4 // larger number faster rotation
    
    var xVector : CGFloat = 0
    var yVector : CGFloat = 0
    var rotationVector : CGVector = .zero
    var thrustFactor : CGFloat = 1.0//larger fast
    let thrustSound = SKAction.repeatForever(SKAction.playSoundFileNamed("thrust.wav", waitForCompletion: true))
    
    //Method
    override func didMove(to view: SKView) {
        setupLabelsAndButtons()
        createPlayeer(atX: frame.width/2, atY:frame.height/2 )
    }
    
    override func update(_ currentTime: TimeInterval) {
        if isRotatingLeft {
            rotation += rotationFactor
            if rotation == 360 { rotation = 0 }// It will keep adding otherwise
            
        }
        else if isRotatingRight {
            rotation -= rotationFactor
            if rotation < 0 { rotation = 360 - rotationFactor}
        }
        if isThrustOn {
            xVector = sin(player.zRotation) * -thrustFactor
            yVector = cos(player.zRotation) * thrustFactor
            rotationVector = CGVector(dx: xVector, dy: yVector)
            player.physicsBody?.applyImpulse(rotationVector)
        }
        if isBacking {
            xVector = sin(player.zRotation) * -thrustFactor
            yVector = cos(player.zRotation) * thrustFactor
            rotationVector = CGVector(dx: -xVector, dy: -yVector)
            player.physicsBody?.applyImpulse(rotationVector)
        }
        if player.position.y > frame.height { player.position.y = 0}
        if player.position.y < 0 { player.position.y = frame.height}
        if player.position.x < 0 { player.position.x = frame.width}
        if player.position.x > frame.width { player.position.x = 0}
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let location = touch.location(in: self)//Finds location of tap
        let tappedNodes = nodes(at: location)//Gets the tapped nodes
        guard let tapped = tappedNodes.first else {return} //gets the first one
        
        switch tapped.name {// if the name
        case "Left":
            isRotatingLeft = true
            isRotatingRight = false
        case "Right":
            isRotatingLeft = false
            isRotatingRight = true
        case "Thrust" :
            isThrustOn = true
            player.texture = SKTexture(imageNamed: "ship-moving")
            scene?.run(thrustSound, withKey: "thrustSound")
        case "Back" :
            isBacking = true
            scene?.run(thrustSound, withKey: "thrustSound")
            
        case "Hyper" :
            animateHyperSpace()
        default :
            return
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
            guard let touch = touches.first else {return}
            let location = touch.location(in: self)
            let tappedNodes = nodes(at: location)
            guard let tapped = tappedNodes.first else {return}
            
            switch tapped.name {
            case "Left":
                isRotatingLeft = false
                isRotatingRight = false
            case "Right":
                isRotatingLeft = false
                isRotatingRight = false
            case "Thrust" :
                isThrustOn = false
                player.texture = SKTexture(imageNamed: "ship-still")
                scene?.removeAction(forKey: "thrustSound")
            case "Back" :
                isBacking = false
                scene?.removeAction(forKey: "thrustSound")
              
            default :
                return
            }
    }
    //MARK : Node methods
    func setupLabelsAndButtons(){
        left = childNode(withName: "left") as? SKSpriteNode
        right = childNode(withName: "right") as? SKSpriteNode
        hyper = childNode(withName: "hyper") as? SKSpriteNode
        thrust = childNode(withName: "thrust") as? SKSpriteNode
        fire = childNode(withName: "fire") as? SKSpriteNode
        back = childNode(withName: "back") as? SKSpriteNode
    }
    func createPlayeer(atX: Double, atY: Double) {
        guard childNode(withName: "player") == nil else {return}//make else
        player.position = CGPoint(x: atX, y: atY)
        player.zPosition = 0
        player.size = CGSize(width: 120, height: 120)
        player.name = "player"
        player.texture = SKTexture(imageNamed: "ship-still")
        addChild(player)
        
        player.physicsBody = SKPhysicsBody(texture: player.texture ?? SKTexture(imageNamed: "ship-still"), size: player.size)
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.isDynamic = true//
        player.physicsBody?.mass = 0.2 // Helps control shift
        player.physicsBody?.allowsRotation = false // prevents from being turned by objects
        
        isPlayerAlive = true
    }
    func animateHyperSpace(){
        let outAnimation : SKAction = SKAction(named: "outAnimation")!
        let inAnimation : SKAction = SKAction(named: "inAnimation")!
        let randomX : CGFloat = CGFloat.random(in: 100...1948)
        let randomY : CGFloat = CGFloat.random(in: 150...1436)
        let stopShooting = SKAction.run {
            self.isHyperSpacing = true
        }
        let startShooting = SKAction.run {
            self.isHyperSpacing = false
        }
        let movePlayer = SKAction.move(to: CGPoint(x: randomX, y: randomY), duration: 0)
        let wait = SKAction.wait(forDuration: 0.25)
        let animation = SKAction.sequence([stopShooting, outAnimation, wait, movePlayer, wait, inAnimation, startShooting])
        player.run(animation)
    }
}
