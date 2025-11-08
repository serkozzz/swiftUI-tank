//
//  TankView.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 16.09.2025.
//



import SwiftUI
import simd
import TankEngine2D

struct TankView: View {
    @State private var appeared = false
    
    @ObservedObject var tank: PlayerTank
    @State private var turretRotation: Angle = .zero
    @State private var lastTurretRotation: Angle = .zero
    var id = UUID()
    
    let animation = Animation
        .linear(duration: 4)
        .repeatForever(autoreverses: false)
    
    init (tank: PlayerTank) {
        self._tank = ObservedObject(initialValue: tank)
    }

    
    var body: some View {
        return HStack {
            ZStack {
                let width = tank.tankSize.width
                let height = tank.tankSize.height
                
                //body
                Rectangle().stroke(.black)
                    .frame(width: width , height: height)
                
                Group {
                    // turret
                    Rectangle().stroke(.black).frame(width: width/2, height: height / 3)
                    
                    //barrel
                    Rectangle()
                        .fill(.black)
                        .frame(width: height/1.5, height: 2)    //палочка
                        .rotationEffect(Angle.degrees(90))
                        .offset(y: height/1.5 / 2 + height / 6 )
                        .background(.yellow)
                }
                .rotationEffect(turretRotation)
                .animation(.default, value: turretRotation)
            }

        }
        .onAppear() {
            calculateTurretRotation()
//            withAnimation(animation) {
//                appeared = true
//            }
        }
        .onChange(of: tank.barrelDirection) {
            calculateTurretRotation()
        }
    }
    
    private func calculateTurretRotation() {
        
        let barrelDirection = tank.barrelDirection
//        print (barrelDirection)
        let upVector = SIMD2<Float>(0, 1)
        let dot = dot(barrelDirection, upVector)
        var newAngle = acos(dot / (simd_length(upVector) * simd_length(barrelDirection)))
        
        let cross = cross(upVector, barrelDirection)
        if (cross.z < 0) {
            newAngle = -newAngle
        }
//        print (newAngle)
        let nearestAngle = nearestRotationAngle(new: newAngle,                                                old: Float(self.lastTurretRotation.radians))
        self.turretRotation = Angle(radians: Double(nearestAngle))
        self.lastTurretRotation = turretRotation

        
    }
    
    private func nearestRotationAngle(new: Float, old: Float) -> Float {
        var delta = new - old
        // Нормализуем дельту в диапазон -π...π
        while delta > .pi { delta -= 2 * .pi }
        while delta < -.pi { delta += 2 * .pi }
        return old + delta
    }
}


#Preview {
    @Previewable @State var playerTank = PlayerTank()
    @Previewable @State var scene = TEScene2D.default
    let game = GameLevelContext(scene: TEScene2D.default,
                                playerTank: playerTank,
                                playerController: PlayerController(playerTank, scene: scene
                                                                  ))
    TankView(tank: game.playerTank)
}



extension TankView: TEView2D {
    
    init(viewModel: TEComponent2D?) {
        let tank = viewModel as! PlayerTank
        self._tank = ObservedObject(initialValue: tank)
    }
    
    var boundingBox: CGSize {
        tank.tankSize
    }
    
    func getViewModel() -> TEComponent2D? {
        tank
    }
}
