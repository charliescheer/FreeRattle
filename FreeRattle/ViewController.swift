//
//  ViewController.swift
//  FreeRattle
//
//  Created by Charlie Scheer on 11/29/19.
//  Copyright © 2019 Praxsis. All rights reserved.
//

import UIKit
import CoreMotion
import AVFoundation

class ViewController: UIViewController  {

    @IBOutlet weak var rattleImage: UIImageView!
    
    let gestureRecognizer: UIGestureRecognizer = UIGestureRecognizer()
    let motionManager: CMMotionManager = CMMotionManager()
    var rattleSound: AVAudioPlayer?
    var running = false
    var rotateRan = true
    
    @IBAction func imageWasTapped(_ sender: Any) {
        rotateRattle(Direction.left)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rattleImage.isUserInteractionEnabled = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        motionManager.accelerometerUpdateInterval = 0.1
        let operationQueue = OperationQueue()
        
        motionManager.startAccelerometerUpdates(to: operationQueue) { (data, error) in
            if let data = data {
                self.triggerRattleFromRotationWith(data, ran: self.rotateRan)
            }
        }
    }
    
    func triggerRattleFromRotationWith(_ data: CMAccelerometerData, ran: Bool)  {
        if ran == true {
            if data.acceleration.x < -0.7 || data.acceleration.x > 0.7 {
                print("rotated")
                print(data.acceleration.x)
                DispatchQueue.main.async {
                    if self.rotateRan == false {
                        if data.acceleration.x < 0 {
                            print("left")
                            self.rotateRattle(Direction.left)
                        } else if data.acceleration.x > 0 {
                            print("right")
                            self.rotateRattle(Direction.right)
                        }
                    }
                }
                rotateRan = false
            }
        } else {
            if data.acceleration.x > -0.3 && data.acceleration.x < 0.3 {
                rotateRan = true
            }
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        return true
    }
    
    
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            rotateRattle(Direction.left)
            print("shake")
        }
    }
    
    func rotateRattle(_ direction: Direction) {
        running = true
        
        let animations = createAnimationsArray(direction)
        triggerAnimation(animations)
        
        let path = Bundle.main.path(forResource: "rattle-short.mp3", ofType: nil)!
        let url = URL(fileURLWithPath: path)
        
        do {
            rattleSound = try AVAudioPlayer(contentsOf: url)
            rattleSound?.play()
        } catch {
            print("oops")
        }
        
    }
    
    fileprivate func triggerAnimation(_ animations: [CABasicAnimation]) {
        //Animation group test
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 3
        animationGroup.repeatCount = 1
        animationGroup.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animationGroup.animations = animations
        
        
        rattleImage.layer.add(animationGroup, forKey: "rotationAnimation")
    }

    fileprivate func createAnimationsArray(_ direction: Direction) -> [CABasicAnimation] {
        var directionModifier = 1.0
        
        if direction == Direction.left {
            directionModifier = -1.0
        }
        
        
        var animations = [CABasicAnimation]()
        
        let animation1 = CABasicAnimation(keyPath: "transform.rotation.z")
        animation1.toValue = 0.1 * directionModifier
        animation1.duration = 0.01
        animations.append(animation1)
        
        let animation2 = CABasicAnimation(keyPath: "transform.rotation.z")
        animation2.fromValue = 0.1 * directionModifier
        animation2.toValue = 0.2 * directionModifier
        animation2.duration = 0.01
        animation2.beginTime = 0.01
        animation2.autoreverses = true
        animation2.repeatCount = 10
        animations.append(animation2)
        
        let animation3 = CABasicAnimation(keyPath: "transform.rotation.z")
        animation3.fromValue = 0.2 * directionModifier
        animation3.toValue = 0
        animation3.duration = 0.1
        animation3.beginTime = 0.15
        animations.append(animation3)
        
        return animations
    }
    
    
}

extension ViewController: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        running = false
    }
}

enum Direction {
    case left
    case right
}
