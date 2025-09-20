//
//  TankView.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 16.09.2025.
//



import SwiftUI
import simd

struct TankView: View {
    @State private var appeared = false
    
    @ObservedObject var tank: PlayerTank
    @State private var turretRotation: Float = 0
    @State private var lastTurretRotation: Float = 0
    
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
                        .offset(y: -height/1.5 / 2 - height / 6 )
                        .background(.yellow)
                }
                .rotationEffect(Angle.radians(Double(turretRotation)))
                .animation(.default, value: turretRotation)
            }

        }
        .onAppear() {
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
        let upVector = SIMD2<Float>(0, -1)
        let dot = dot(barrelDirection, upVector)
        var newAngle = acos(dot / (simd_length(upVector) * simd_length(barrelDirection)))
        
        let cross = cross(upVector, barrelDirection)
        if (cross.z < 0) {
            newAngle = -newAngle
        }
        self.turretRotation = nearestRotationAngle(new: newAngle, old: self.lastTurretRotation)
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
    let game = GameModel()
    TankView(tank: game.player)
}



