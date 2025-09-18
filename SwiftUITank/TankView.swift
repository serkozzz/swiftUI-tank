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
    @State private var tankSize = CGSize(width: 40, height: 60)
    
    private var barrelDirection: SIMD2<Float>
    @State private var turretRotation: Float = 0
    @State private var lastTurretRotation: Float = 0
    
    let animation = Animation
        .linear(duration: 4)
        .repeatForever(autoreverses: false)
    
    init (barrelDirection: SIMD2<Float>) {
        self.barrelDirection = barrelDirection
    }

    
    var body: some View {
        return HStack {
            ZStack {
                //body
                Rectangle().stroke(.black)
                    .frame(width: tankSize.width, height: tankSize.height)
                
                Group {
                    // turret
                    Rectangle().stroke(.black).frame(width: tankSize.width/2, height: tankSize.height / 3)
                    
                    //barrel
                    Rectangle()
                        .fill(.black)
                        .frame(width: tankSize.height/1.5, height: 2)    //палочка
                        .rotationEffect(Angle.degrees(90))
                        .offset(y: -tankSize.height/1.5 / 2 - tankSize.height / 6 )
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
        .onChange(of: barrelDirection) {
            calculateTurretRotation()
        }
    }
    
    private func calculateTurretRotation() {
        
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
    TankView(barrelDirection: SIMD2<Float>(x: 0, y: 1))
}



