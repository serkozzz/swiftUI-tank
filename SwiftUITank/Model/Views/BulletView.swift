//
//  Bullet.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 30.09.2025.
//

import SwiftUI
import simd

struct BulletView: View {
    let bullet: Bullet
    
    var body: some View {
        Rectangle().fill(.black)
    }
}

#Preview {
    @Previewable @State var playerTank = PlayerTank()
    BulletView(bullet: Bullet(playerTank, startPosition: SIMD2<Float>(x: 0, y: 0), directionVector:SIMD2<Float>.one))
}
