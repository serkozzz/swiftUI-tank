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
    var player: PlayerLogic
    
    var boundingBox: CGSize {
        return CGSize(width: 10, height: 10)
    }
    
    init(viewModel: TankEngine2D.TEComponent2D?) {
        id = UUID()
        self.player = viewModel as! PlayerLogic
    }
    
    func getViewModel() -> TankEngine2D.TEComponent2D? {
        return player
    }
    
    var body: some View {
        Rectangle()
            .fill(Color.red)
            .frame(width: 100, height: 100)
    }
}
