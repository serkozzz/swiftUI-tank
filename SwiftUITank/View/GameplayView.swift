//
//  TankController.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 18.09.2025.
//

import SwiftUI
import TankEngine2D
import simd

struct GameplayView: View {

    var playerController: PlayerController
    @ObservedObject var player: PlayerTank
    @ObservedObject var scene: TEScene2D
    
    init(levelManager: GameLevelManager) {
        let context = levelManager.levelContext
        self._player = ObservedObject(initialValue: context.playerTank)
        self._scene = ObservedObject(initialValue: context.scene)
        self.playerController = context.playerController
    }
    
    
    var body: some View {
        VStack {
            ZStack {
                TESceneRender2D(scene: scene)
                
                // Левый стик — снизу слева
                VStack {
                    Spacer()
                    HStack {
                        Joystick(id: .left, delegate: playerController)
                            .frame(width: 100, height: 100)
                        Spacer()
                    }
                }
                .padding()
                
                // Правый стик — снизу справа
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Joystick(id: .right, delegate: playerController)
                            .frame(width: 100, height: 100)
                    }
                }
                .padding()
            }
            HStack {
                Button("Play") {
                    TETankEngine2D.shared.start()
                }
                Button("Pause") {
                    TETankEngine2D.shared.pause()
                }
                Button("up") {
                    scene.camera.move(simd_float2(0, 10))
                }
                Button("down") {
                    scene.camera.move(simd_float2(0, -10))
                }
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onChanged() { value in
                    playerController.touchChanged(at: value.location)
                   
                }
                .onEnded() {_ in
                    playerController.touchEnded()
                }
        )
    }
}

#Preview {
    GameplayView(levelManager: GameLevelManager(scene: TEScene2D.default))
}
