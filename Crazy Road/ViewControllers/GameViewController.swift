//
//  GameViewController.swift
//  Crazy Road
//
//  Created by Dmytrii  on 26.11.2025.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    @IBOutlet weak var skView: SKView!
    @IBOutlet weak var timerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Game"
        timerLabel.text = "Time: 0.0s"
        setupGame()
        setupSwipeGesture()
    }
    
    func setupGame() {
        let scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        skView.presentScene(scene)
        
        skView.showsFPS = true
        skView.showsNodeCount = true
    }
    
    func updateTimerLabel(timeString: String) {
        timerLabel.text = "Time: \(timeString)s"
    }
    
    func setupSwipeGesture() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown))
        swipeDown.direction = .down
        skView.addGestureRecognizer(swipeDown)
    }

    @objc func handleSwipeDown() {
        guard let scene = skView.scene as? GameScene else { return }
        scene.movePlayerDown()
    }
}

