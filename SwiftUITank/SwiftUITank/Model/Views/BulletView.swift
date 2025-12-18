//
//  Bullet.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 30.09.2025.
//

import SwiftUI
import simd
import TankEngine2D

struct BulletView: View {
    var viewModel: Bullet
    var id = UUID()
    
    init(viewModel: Bullet) {
        self.viewModel = viewModel
    }
    
    
    var body: some View {
        Rectangle().fill(.black)
    }
}


#Preview {
    @Previewable @State var playerTank = PlayerTank()
    BulletView(viewModel: Bullet(playerTank, startPosition: SIMD2<Float>(x: 0, y: 0), directionVector:SIMD2<Float>.one))
}
