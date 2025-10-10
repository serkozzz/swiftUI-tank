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
    
    @State private var barrelDirection = SIMD2<Float>(0, -1)
    @State private var isTouched = false

    @State private var playerController: PlayerController
    @ObservedObject var player: PlayerTank
    @ObservedObject var scene: TEScene2D
    
    init(levelManager: GameLevelManager) {
        let context = levelManager.levelContext
        self._player = ObservedObject(initialValue: context.playerTank)
        self._scene = ObservedObject(initialValue: context.scene)
        self._playerController = State(initialValue: PlayerController(gameLevelManager: levelManager))
    }
    
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottomTrailing) {
                TESceneRender2D(scene: scene)
                Joystick(delegate: playerController)
                    .frame(width: 100, height: 100)
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
                    if (!isTouched) {
                        isTouched = true
                    }
                    let worldTouch = scene.camera.screenToWorld(
                        SIMD2<Float>(value.location)
                    )
                    
                    player.barrelDirection = worldTouch - player.transform!.position
                }
                .onEnded() {_ in
                    isTouched = false
                }
        )
    }
}

#Preview {
    GameplayView(levelManager: GameLevelManager(scene: TEScene2D.default))
}

