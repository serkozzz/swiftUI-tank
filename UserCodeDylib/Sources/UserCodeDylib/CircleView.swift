//
//  CircleView.swift
//  SimpleGame
//
//  Created by Sergey Kozlov on 07.11.2025.
//

import SwiftUI
import TankEngine2D

struct CircleView : TEView2D {
    var id: UUID
    
    var boundingBox: CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    init(viewModel: TankEngine2D.TEComponent2D?) {
        id = UUID()
    }
    
    func getViewModel() -> TankEngine2D.TEComponent2D? {
        nil
    }
    
    var body: some View {
        Circle()
            .fill(Color.red)
            .frame(width: 100, height: 100)
    }
}
