//
//  CircleView.swift
//  SimpleGame
//
//  Created by Sergey Kozlov on 07.11.2025.
//

import SwiftUI
import TankEngine2D 


struct CircleView : View {
    @ObservedObject var viewModel: CircleViewModel
    
    init(viewModel: CircleViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        Circle()
            .fill(Color.red)
            .frame(width: 100, height: 100)
    }
}
