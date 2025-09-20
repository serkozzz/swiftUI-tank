//
//  TankController.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 18.09.2025.
//

import SwiftUI

struct PlayerController: ViewModifier {
    
    @State private var barrelDirection = SIMD2<Float>(0, -1)
    @State private var tankCenter: CGPoint!
    @State private var isTouched = false

    
    @State private var playerMover: PlayerMover
    @ObservedObject var player: PlayerTank
    @ObservedObject var scene: Scene2D
    
    init(scene: Scene2D) {
        self._player = ObservedObject(initialValue: scene.player)
        self._scene = ObservedObject(initialValue: scene)
        self._playerMover = State(initialValue: PlayerMover(playerTank: scene.player))
    }
    
    
    func body(content: Content) -> some View {
        ZStack(alignment: .bottomTrailing) {
            content
                SceneRender(scene: scene)
                .onPreferenceChange(CenterPreferenceKey.self) { value in
                    self.tankCenter = value
                }
            Joystick(delegate: playerMover)
                .frame(width: 100, height: 100)
            
        }
        .background {
            KeyPressHandler { key in
                switch key {
                case .up: player.position.y -= 10
                case .down: player.position.y += 10
                case .left: player.position.x -= 10
                case .right: player.position.x += 10
                }
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .global)
                .onChanged() { value in
                    if (!isTouched) {
                        isTouched = true
                    }
                    let location = value.location
                    player.barrelDirection = SIMD2(Float(location.x - tankCenter.x),
                                            Float(location.y - tankCenter.y))
                }
                .onEnded() {_ in
                    isTouched = false
                }
        )
    }
}

extension View {
    func playerController(scene: Scene2D) -> some View {
        modifier(PlayerController(scene: scene))
    }
}



#Preview {
    Color.clear
        .playerController(scene: GameModel().scene)
}
