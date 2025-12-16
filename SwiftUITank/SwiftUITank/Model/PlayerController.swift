//
//  PlayerController.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 02.10.2025.
//

import SwiftUI
import Combine
import simd
import TankEngine2D

@MainActor
protocol PlayerControllerDelegate: AnyObject {
    func playerController(_ playerController: PlayerController, initiatedShootingWith bullet: Bullet)
}

@TESerializable @MainActor
class PlayerController: TEComponent2D {
    
    weak var delegate: PlayerControllerDelegate?
    
    private var playerMover: PlayerMover!
    private var tankTurretMover: TankTurretMover!
    private var playerTank: PlayerTank!
    private var scene: TEScene2D!
    
    private var isTouched: Bool = false
    required init() {
        super.init()
    }
    
    override func awake() {
        //TODO Injection
        playerTank = TETankEngine2D.findNodeWith(tag: "PlayerTank")!.getComponent(PlayerTank.self)
        self.scene = TETankEngine2D.shared.scene
        self.playerMover = PlayerMover(playerTank, tankEngine2D: TETankEngine2D.shared)
        self.tankTurretMover = TankTurretMover(playerTank, tankEngine2D: TETankEngine2D.shared)
    }
    
    override func update(timeFromLastUpdate: TimeInterval) {
        playerMover.update(timeFromLastUpdate: timeFromLastUpdate)
        tankTurretMover.update(timeFromLastUpdate: timeFromLastUpdate)
    }
}


//MARK: JOYSTICK
extension PlayerController: JoystickDelegate {
    func joystickDidReceiveDoubleTap(id: JoystickID) {
        switch id {
        case .left:
            delegate?.playerController(self, initiatedShootingWith: (playerTank.shoot()))
        case .right:
            delegate?.playerController(self, initiatedShootingWith: (playerTank.shoot()))
        }
    }
    
    
    func joystickDidBegin(id: JoystickID) {
        switch id {
        case .left:
            self.tankTurretMover.joystickDidBegin()
        case .right:
            self.playerMover.joystickDidBegin()
            break
        }
    }
    
    func joystickDidChange(id: JoystickID, to state: JoystickState) {
        switch id {
        case .left:
            self.tankTurretMover.joystickDidChange(to: state)
        case .right:
            self.playerMover.joystickDidChange(to: state)
            break
        }
    }
    
    func joystickDidEnd(id: JoystickID) {
        switch id {
        case .left:
            self.tankTurretMover.joystickDidEnd()
        case .right:
            self.playerMover.joystickDidEnd()
            break
        }
    }
}

//MARK: drag gesture
extension PlayerController {
    
    func touchChanged(at screenPoint: CGPoint) {
        if (!isTouched) {
            isTouched = true
        }
        let worldTouch = scene.camera.screenToWorld(
            SIMD2<Float>(screenPoint)
        )
        
        let worldBarrelDirection = worldTouch - playerTank.worldTransform!.position
        let inverteMatirx = playerTank.worldTransform!.matrix.inverse
        let localBarrelDirection = inverteMatirx * SIMD3<Float>(worldBarrelDirection, 0)
        playerTank.barrelDirection = SIMD2<Float>(localBarrelDirection)
    }
    
    func touchEnded() {
        isTouched = false
    }
}
