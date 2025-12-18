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
    
    init(viewModel: Radar) {
        self.model = viewModel
    }
    
    var body: some View {
        Rectangle().stroke(model.color)
        
    }
}



#Preview {
    RadarView(viewModel: Radar(color: .blue))
}
