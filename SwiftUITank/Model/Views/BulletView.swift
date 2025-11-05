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
    var model: Bullet
    
    var body: some View {
        Rectangle().fill(.black)
    }
}


extension BulletView: TEView2D {
    var boundingBox: CGSize {
        model.size.cgSize
    }
    
    init(viewModel: TankEngine2D.TEComponent2D?) {
        let bullet = viewModel as! Bullet
        self.model = bullet
    }
    
    func getViewModel() -> TankEngine2D.TEComponent2D {
        model
    }
}


#Preview {
    @Previewable @State var playerTank = PlayerTank()
    BulletView(model: Bullet(playerTank, startPosition: SIMD2<Float>(x: 0, y: 0), directionVector:SIMD2<Float>.one))
}
