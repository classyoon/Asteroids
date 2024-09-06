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
    
    
//    let enemy = SKSpriteNode(imageNamed: "alien-ship")
//    var isEnemyAlive = false
//    var isEnemyBig = true
//    var enemyTimer : Double = 0
    
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
        
      //  enemyTimer = Double.random(in: 1800...7200)//should be 30-120 seconds
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
        
 
         
//                createEnemySpaceShip()
          
        
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
        case "Fire":
            createPlayerBullet()
          //  createEnemySpaceShip()
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
    
    func createPlayerBullet(){
        guard isHyperSpacing == false && isPlayerAlive == true else { return}
        let bullet = SKShapeNode(ellipseOf: CGSize(width: 10, height: 10))
        let shotSound = SKAction.playSoundFileNamed("fire.wav", waitForCompletion: false)
        let move = SKAction.move(to: findDestination(start: player.position, angle: rotation), duration: 0.5)
        let sequence = SKAction.sequence([shotSound, move, .removeFromParent()])
        
        bullet.position = player.position
        
        bullet.zPosition = 0
        bullet.fillColor = .white
        bullet.name = "playerBullet"
        addChild(bullet)
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: 3, center: player.position)
        bullet.physicsBody?.affectedByGravity = false
        bullet.physicsBody?.isDynamic = true
        bullet.run(sequence)
    }
//    func createEnemySpaceShip() {
//        guard isEnemyAlive == false else {return}
//        isEnemyAlive = true
//        let startOnLeft = Bool.random()
//        let startY = Double.random(in: 150...1436)
//        
//      //  isEnemyBig = score > 40000 ? false : Bool.random()
//        isEnemyBig = Bool.random()
//        enemy.position = startOnLeft ? CGPoint(x: -100, y: startY) : CGPoint(x: 2248, y: startY)
//        enemy.zPosition = 0
//        enemy.size = CGSize(width: isEnemyBig ? 120 : 60, height: isEnemyBig ? 120 : 60)
//        enemy.name = isEnemyBig ? "enemy-large" : "enemy-small"
//        addChild(enemy)
//        enemy.physicsBody = SKPhysicsBody(texture: enemy.texture!, size: enemy.size)
//        enemy.physicsBody?.affectedByGravity = false
//        enemy.physicsBody?.isDynamic = true
//        
//        let firstMove = SKAction.move(to: startOnLeft ? CGPoint(x: 716, y: startY + Double.random(in: -500...500)) : CGPoint(x: 1432, y: Double.random(in: -500...500)), duration: 3)//zig zag move
//        let secondMove = SKAction.move(to: startOnLeft ? CGPoint(x: 1432, y: startY + Double.random(in: -500...500)) : CGPoint(x: 716, y: Double.random(in: -500...500)), duration: 3)//zig zag move
//        let thirdMove = SKAction.move(to: startOnLeft ? CGPoint(x: 2248, y: startY + Double.random(in: -500...500)) : CGPoint(x: -100, y: Double.random(in: -500...500)), duration: 3)//zig zag move
//        let remove = SKAction.run {
//            self.isEnemyAlive = false
//            self.enemyTimer = Double.random(in: 10...15)
//        }
//        let sound = SKAction.repeatForever(SKAction.playSoundFileNamed("saucerSmall.wav", waitForCompletion: true))// Add saucer big
//        let sequence = SKAction.sequence([firstMove, secondMove, thirdMove, .removeFromParent(), remove])
//        
//        let group = SKAction.group([sound, sequence])
//        enemy.run(group)
//    }
}
