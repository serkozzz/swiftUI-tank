//
//  CircleView.swift
//  SimpleGame
//
//  Created by Sergey Kozlov on 07.11.2025.
//

import SwiftUI
import TankEngine2D

struct RectView : TEView2D {
    var id: UUID
    
    var boundingBox: CGSize = CGSize(width: 100, height: 100)
    
    init(viewModel: TankEngine2D.TEComponent2D?) {
        id = UUID()
    }
    
    func getViewModel() -> TankEngine2D.TEComponent2D? {
        return nil
    }
    
    var body: some View {
        Rectangle()
            .fill(Color.red)
    }
}
