import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scoreLabel: SKLabelNode!
    var ballsRemainingLabel: SKLabelNode!
    var defeatScreenLabel: SKLabelNode!
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var ballsRemaining = 10 {
        didSet {
            ballsRemainingLabel.text = "Balls remaining: \(ballsRemaining)"
        }
    }
    
    var ballsUsed = 10;
    
    var editLabel: SKLabelNode!
    
    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        physicsWorld.contactDelegate = self
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        ballsRemainingLabel = SKLabelNode(fontNamed: "Chalkduster")
        ballsRemainingLabel.text = "Balls remaining: \(ballsRemaining)"
        ballsRemainingLabel.horizontalAlignmentMode = .right
        ballsRemainingLabel.position = CGPoint(x: 650, y: 700)
        addChild(ballsRemainingLabel)

        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
        }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            var location = touch.location(in: self)

            let objects = nodes(at: location)
            
            if objects.contains(editLabel)
            {
                editingMode = !editingMode
            }
            else{
                if editingMode
                {
                    //if touch.location(in: view?.center.x) == 5.00
                   // {
                        
                    //}
                    let size = CGSize(width: GKRandomDistribution(lowestValue: 16, highestValue: 128).nextInt(), height: 16)
                    let box = SKSpriteNode(color: RandomColor(), size: size)
                    box.zRotation = RandomCGFloat(min: 0, max: 3)
                    box.position = location
                    
                    box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                    box.physicsBody?.isDynamic = false
                    box.name = "box"
                    
                    
                    for item in objects
                    {
                        if item.name == "box"
                        {
                            item.removeFromParent()
                            break
                        }
                        else
                        {
                            addChild(box)
                            break
                        }
                    }
                }
                else
                {
                if(ballsUsed > 0)
                {
                    ballsUsed -= 1;
                    var ballColor = ["ballRed", "ballYellow","ballGreen", "ballCyan"]
                    let randomIndex = Int(arc4random_uniform(UInt32(ballColor.count)))
                    let ball = SKSpriteNode(imageNamed: ballColor[randomIndex])
                    ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
                    ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask
                    ball.physicsBody?.restitution = 0.6
                    location.y = 700
                    ball.position = location
                    ball.name = "ball"
                    addChild(ball)
                    
                    }
                }
            }
        }

    }
    
    func moveBox(at position: CGPoint)
    {
        
    }
    
    func makeBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    
    
    
    func makeSlot(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        
        slotBase.position = position
        slotGlow.position = position
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        
        addChild(slotBase)
        addChild(slotGlow)
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    func collisionBetween(ball: SKNode, object: SKNode) {
        
        if object.name == "good" {
            destroy(ball: ball)
            score += 1
            ballsUsed += 2
            print("here \(ballsUsed)")
            ballsRemaining += 1

            
        } else if object.name == "bad" {
            destroy(ball: ball)
            score -= 1
            ballsRemaining -= 1
        }

        if object.name == "box"
        {
            object.removeFromParent()
        }
        
        if(ballsRemaining <= 0)
        {
            defeatScreenLabel = SKLabelNode(fontNamed: "Chalkduster")
            defeatScreenLabel.text = "Game Over!"
            defeatScreenLabel.horizontalAlignmentMode = .right
            defeatScreenLabel.position = CGPoint(x: 600, y: 425)
            defeatScreenLabel.isHidden = false
            addChild(defeatScreenLabel)
            
            let seconds = 4.0
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                self.score = 0;
                self.ballsRemaining = 10;
                self.defeatScreenLabel.isHidden = true
                self.ballsUsed = 5
            }
        }
    }
    
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA.name == "ball" {
            collisionBetween(ball: nodeA, object: nodeB)
        } else if nodeB.name == "ball" {
            collisionBetween(ball: nodeB, object: nodeA)
        }
    }
    
    func destroy(ball: SKNode) {
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
        
        ball.removeFromParent()
    }
    
    }



