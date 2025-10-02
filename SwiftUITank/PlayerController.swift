//
//  TankController.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 18.09.2025.
//

import SwiftUI
import TankEngine2D

struct PlayerController: ViewModifier {
    
    @State private var barrelDirection = SIMD2<Float>(0, -1)
    @State private var isTouched = false

    
    @State private var playerMover: PlayerMover
    @ObservedObject var player: PlayerTank
    @ObservedObject var scene: TEScene2D
    @State private var viewportSize = CGSize.zero
    
    init(scene: TEScene2D, player: PlayerTank) {
        self._player = ObservedObject(initialValue: player)
        self._scene = ObservedObject(initialValue: scene)
        self._playerMover = State(initialValue: PlayerMover(playerTank: player))
    }
    
    
    func body(content: Content) -> some View {
        ZStack(alignment: .bottomTrailing) {
            content
            TESceneRender2D(scene: scene)
                .onGeometryChange(for: CGSize.self,
                                  of: { proxy in proxy.size}) { size in
                    self.viewportSize = size
                }
            Joystick(delegate: playerMover)
                .frame(width: 100, height: 100)
            
        }
        .background {
//            KeyPressHandler { key in
//                switch key {
//                case .up: player.position.y -= 10
//                case .down: player.position.y += 10
//                case .left: player.position.x -= 10
//                case .right: player.position.x += 10
//                }
//            }
        }
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onChanged() { value in
                    if (!isTouched) {
                        isTouched = true
                    }
                    let worldTouch = scene.camera.screenToWorld(
                        SIMD2<Float>(value.location),
                        viewportSize: viewportSize)
                    
                    player.barrelDirection = worldTouch - player.transform!.position
                }
                .onEnded() {_ in
                    isTouched = false
                }
        )
    }
}

extension View {
    func playerController(scene: TEScene2D, player: PlayerTank) -> some View {
        modifier(PlayerController(scene: scene, player: player))
    }
}



#Preview {
    Color.clear
        .playerController(scene: GameContext().scene, player: PlayerTank())
}
