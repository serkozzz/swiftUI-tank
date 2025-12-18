//
//  CircleView.swift
//  SimpleGame
//
//  Created by Sergey Kozlov on 07.11.2025.
//

import SwiftUI
import TankEngine2D


struct RectView : View {
    var viewModel: RectViewModel
    
    init(viewModel: RectViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        Rectangle()
            .fill(Color.blue)
    }
}
