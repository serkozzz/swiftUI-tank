//
//  TestRotator.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 12.10.2025.
//

import SwiftUI
import TankEngine2D

struct RadarView: View {
    @ObservedObject var model: Radar
    var id = UUID()
    var body: some View {
        Rectangle().stroke(model.color)
        
    }
}

extension RadarView: TEView2D {
    var boundingBox: CGSize {
        model.size
    }
    
    init(viewModel: TankEngine2D.TEComponent2D?) {
        let radar = viewModel as! Radar
        self.model = radar
    }
    
    func getViewModel() -> TankEngine2D.TEComponent2D? {
        model
    }
}


#Preview {
    RadarView(model: Radar(color: .blue))
}
