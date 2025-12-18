//
//  TERectangleView2D.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 25.11.2025.
//

import SwiftUI

public struct TECircleView2D: View {
    let viewModel: TECircle2D
    
    public init(viewModel: TECircle2D) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        Rectangle()
            .fill(Color.blue)
    }
}
