//
//  GameScene.swift
//  Crazy Road
//
//  Created by Dmytrii  on 26.11.2025.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Properties
    
    var player: SKSpriteNode!
    var lanes: [SKSpriteNode] = []
    var cars: [SKSpriteNode] = []
    
    let laneHeight: CGFloat = 60
    let carWidth: CGFloat = 60
    let carHeight: CGFloat = 30
    let carSpeed: CGFloat = 100
    let cameraSpeed: CGFloat = 20
    
    let totalLanes: Int = {
        let screenHeight = UIScreen.main.bounds.height
        return Int(ceil(screenHeight / 60)) + 5
    }()
    
    var nextLaneIndex: Int = 0
    var gameTime: TimeInterval = 0
    var lastUpdateTime: TimeInterval = 0
    var cameraY: CGFloat = 0
    var lastCameraUpdateTime: TimeInterval = 0
    var gameCamera: SKCameraNode!
    
    // MARK: - Lifecycle
    
    override func didMove(to view: SKView) {
        setupScene()
        setupLanes()
        setupPlayer()
        startCarSpawning()
    }
    
    override func update(_ currentTime: TimeInterval) {
        updateTimer(currentTime)
        updateCamera(currentTime)
    }
    
    // MARK: - Setup
    
    func setupScene() {
        backgroundColor = .black
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = .zero
        setupCamera()
    }
    
    func setupCamera() {
        gameCamera = SKCameraNode()
        camera = gameCamera
        cameraY = frame.height / 2
        gameCamera.position = CGPoint(x: frame.midX, y: cameraY)
        addChild(gameCamera)
    }
    
    func setupLanes() {
        for i in 0..<totalLanes {
            let yPosition = CGFloat(i) * laneHeight
            let isGrass = (i % 2 == 0)
            let lane = createLaneWithTexture(isGrass: isGrass, yPosition: yPosition)
            addChild(lane)
            lanes.append(lane)
        }
        nextLaneIndex = totalLanes
    }
    
    func addNewLane() {
        let laneIndex = nextLaneIndex
        nextLaneIndex += 1
        let yPosition = CGFloat(laneIndex) * laneHeight
        let isGrass = (laneIndex % 2 == 0)
        let lane = createLaneWithTexture(isGrass: isGrass, yPosition: yPosition)
        addChild(lane)
        lanes.append(lane)
    }
    
    func removeOldLanes() {
        let cameraBottom = cameraY - frame.height / 2
        let removeThreshold = cameraBottom - 200
        
        lanes.removeAll { lane in
            if lane.position.y < removeThreshold {
                lane.removeFromParent()
                return true
            }
            return false
        }
    }
    
    func updateInfiniteLanes() {
        let cameraTop = cameraY + frame.height / 2
        let highestLaneY = CGFloat(nextLaneIndex - 1) * laneHeight + laneHeight / 2
        
        if cameraTop > highestLaneY - (laneHeight * 3) {
            for _ in 0..<3 { addNewLane() }
        }
        
        if Int(cameraY) % 60 == 0 {
            removeOldLanes()
        }
    }
    
    func setupPlayer() {
        player = SKSpriteNode(imageNamed: "character")
        player.size = CGSize(width: 80, height: 70)
        player.position = CGPoint(x: frame.midX, y: laneHeight / 2)
        player.zPosition = 10
        
        let bodySize = CGSize(width: player.size.width * 0.6, height: player.size.height * 0.6)
        player.physicsBody = SKPhysicsBody(rectangleOf: bodySize)
        player.physicsBody?.isDynamic = false
        player.physicsBody?.categoryBitMask = 2
        player.physicsBody?.contactTestBitMask = 1
        player.physicsBody?.collisionBitMask = 0
        
        addChild(player)
        player.setScale(1.0)
    }
    
    // MARK: - Cars
    
    func spawnCar() {
        var roadIndices: [Int] = []
        for i in 0..<totalLanes where i % 2 == 1 {
            roadIndices.append(i)
        }
        
        guard !roadIndices.isEmpty else { return }
        
        var availableOptions: [(roadIndex: Int, direction: Bool)] = []
        
        for roadIndex in roadIndices {
            let roadY = CGFloat(roadIndex) * laneHeight + laneHeight / 2
            var rightIsFree = true
            var leftIsFree = true
            
            for car in cars {
                guard abs(car.position.y - roadY) < 5 else { continue }
                
                let carX = car.position.x
                if carX > -50 && carX < frame.width + 50 {
                    let isCarMovingRight = car.xScale < 0
                    
                    if isCarMovingRight {
                        leftIsFree = false
                        if carX < 200 { rightIsFree = false }
                    } else {
                        rightIsFree = false
                        if carX > frame.width - 200 { leftIsFree = false }
                    }
                }
            }
            
            if rightIsFree { availableOptions.append((roadIndex, true)) }
            if leftIsFree { availableOptions.append((roadIndex, false)) }
        }
        
        guard !availableOptions.isEmpty else { return }
        
        let choice = availableOptions.randomElement()!
        let roadY = CGFloat(choice.roadIndex) * laneHeight + laneHeight / 2
        let movingRight = choice.direction
        let startX: CGFloat = movingRight ? -carWidth : frame.width + carWidth
        
        let carImages = ["car_red", "car_blue", "car_green"]
        let randomCar = carImages.randomElement()!
        
        let car = SKSpriteNode(imageNamed: randomCar)
        car.size = CGSize(width: carWidth, height: carHeight)
        car.position = CGPoint(x: startX, y: roadY)
        car.zPosition = 5
        
        if randomCar == "car_green" {
            car.xScale = movingRight ? 1 : -1
        } else {
            car.xScale = movingRight ? -1 : 1
        }
        
        let carBodySize = CGSize(width: carWidth * 0.6, height: carHeight * 0.6)
        car.physicsBody = SKPhysicsBody(rectangleOf: carBodySize)
        car.physicsBody?.isDynamic = true
        car.physicsBody?.affectedByGravity = false
        car.physicsBody?.allowsRotation = false
        car.physicsBody?.categoryBitMask = 1
        car.physicsBody?.contactTestBitMask = 2
        car.physicsBody?.collisionBitMask = 0
        
        addChild(car)
        cars.append(car)
        moveCar(car, movingRight: movingRight)
    }
    
    func moveCar(_ car: SKSpriteNode, movingRight: Bool) {
        let endX: CGFloat = movingRight ? frame.width + carWidth : -carWidth
        let distance = abs(endX - car.position.x)
        let duration = TimeInterval(distance / carSpeed)
        
        let move = SKAction.moveTo(x: endX, duration: duration)
        let remove = SKAction.run { [weak self] in
            self?.removeCar(car)
        }
        
        car.run(SKAction.sequence([move, remove]), withKey: "move")
    }
    
    func removeCar(_ car: SKSpriteNode) {
        car.removeFromParent()
        cars.removeAll { $0 == car }
    }
    
    func startCarSpawning() {
        let wait = SKAction.wait(forDuration: 0.5)
        let spawn = SKAction.run { [weak self] in
            self?.spawnCar()
        }
        run(SKAction.repeatForever(SKAction.sequence([wait, spawn])), withKey: "carSpawning")
    }
    
    // MARK: - Touch Controls
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        movePlayerUp()
    }
    
    func movePlayerUp() {
        let newY = player.position.y + laneHeight
        let startY = player.position.y
        let midY = startY + laneHeight / 2 + 15
        
        let jumpUp = SKAction.moveTo(y: midY, duration: 0.15)
        jumpUp.timingMode = .easeOut
        
        let jumpDown = SKAction.moveTo(y: newY, duration: 0.15)
        jumpDown.timingMode = .easeIn
        
        let jumpSequence = SKAction.sequence([jumpUp, jumpDown])
        
        let squash = SKAction.scaleY(to: 0.8, duration: 0.1)
        let stretch = SKAction.scaleY(to: 1.2, duration: 0.1)
        let normal = SKAction.scaleY(to: 1.0, duration: 0.1)
        let scaleSequence = SKAction.sequence([squash, stretch, normal])
        
        player.run(SKAction.group([jumpSequence, scaleSequence]))
    }
    
    func movePlayerDown() {
        let newY = player.position.y - laneHeight
        guard newY >= laneHeight / 2 else { return }
        
        let startY = player.position.y
        let midY = startY - laneHeight / 2 - 15
        
        let jumpDown = SKAction.moveTo(y: midY, duration: 0.15)
        jumpDown.timingMode = .easeOut
        
        let land = SKAction.moveTo(y: newY, duration: 0.15)
        land.timingMode = .easeIn
        
        let jumpSequence = SKAction.sequence([jumpDown, land])
        
        let squash = SKAction.scaleY(to: 0.8, duration: 0.1)
        let stretch = SKAction.scaleY(to: 1.2, duration: 0.1)
        let normal = SKAction.scaleY(to: 1.0, duration: 0.1)
        let scaleSequence = SKAction.sequence([squash, stretch, normal])
        
        player.run(SKAction.group([jumpSequence, scaleSequence]))
    }
    
    // MARK: - Collisions
    
    func didBegin(_ contact: SKPhysicsContact) {
        handleCollision()
    }
    
    func handleCollision() {
        isPaused = true
        removeAction(forKey: "carSpawning")
        ResultsManager.shared.saveResult(time: gameTime)
        showGameOver()
    }
    
    func showGameOver() {
        let timeString = String(format: "%.1f", gameTime)
        let alert = UIAlertController(
            title: "💥 Game Over!",
            message: "Вас збив автомобіль!\n\nВаш час: \(timeString)s",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Restart", style: .default) { [weak self] _ in
            self?.restartGame()
        })
        
        alert.addAction(UIAlertAction(title: "Menu", style: .cancel) { [weak self] _ in
            if let navController = self?.view?.window?.rootViewController as? UINavigationController {
                navController.popViewController(animated: true)
            }
        })
        
        view?.window?.rootViewController?.present(alert, animated: true)
    }
    
    func restartGame() {
        let newScene = GameScene(size: size)
        newScene.scaleMode = scaleMode
        view?.presentScene(newScene, transition: SKTransition.fade(withDuration: 0.5))
    }
    
    // MARK: - Timer
    
    func updateTimer(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
            return
        }
        
        gameTime += currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        if let navController = view?.window?.rootViewController as? UINavigationController,
           let gameVC = navController.viewControllers.first(where: { $0 is GameViewController }) as? GameViewController {
            gameVC.updateTimerLabel(timeString: String(format: "%.1f", gameTime))
        }
    }
    
    // MARK: - Camera
    
    func updateCamera(_ currentTime: TimeInterval) {
        if lastCameraUpdateTime == 0 {
            lastCameraUpdateTime = currentTime
            return
        }
        
        let deltaTime = currentTime - lastCameraUpdateTime
        lastCameraUpdateTime = currentTime
        
        cameraY += cameraSpeed * CGFloat(deltaTime)
        gameCamera.position.y = cameraY
        
        updateInfiniteLanes()
        checkCameraBounds()
    }
    
    func checkCameraBounds() {
        let cameraBottom = cameraY - frame.height / 2
        if player.position.y < cameraBottom - 5 {
            handleCameraGameOver()
        }
    }
    
    func handleCameraGameOver() {
        isPaused = true
        removeAction(forKey: "carSpawning")
        ResultsManager.shared.saveResult(time: gameTime)
        showCameraGameOver()
    }
    
    func showCameraGameOver() {
        let timeString = String(format: "%.1f", gameTime)
        let alert = UIAlertController(
            title: "⏱️ Game Over!",
            message: "Ви не встигли!\n\nВаш час: \(timeString)s",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Restart", style: .default) { [weak self] _ in
            self?.restartGame()
        })
        
        alert.addAction(UIAlertAction(title: "Menu", style: .cancel) { [weak self] _ in
            if let navController = self?.view?.window?.rootViewController as? UINavigationController {
                navController.popViewController(animated: true)
            }
        })
        
        view?.window?.rootViewController?.present(alert, animated: true)
    }
    
    // MARK: - Helpers
    
    func createLaneWithTexture(isGrass: Bool, yPosition: CGFloat) -> SKSpriteNode {
        let textureName = isGrass ? "grass" : "road"
        let lane = SKSpriteNode(imageNamed: textureName)
        lane.size = CGSize(width: frame.width, height: laneHeight)
        lane.position = CGPoint(x: frame.midX, y: yPosition + laneHeight / 2)
        lane.zPosition = -1
        return lane
    }
}

