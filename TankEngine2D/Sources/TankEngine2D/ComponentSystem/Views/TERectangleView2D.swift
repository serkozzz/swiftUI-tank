//
//  TERectangleView2D.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 25.11.2025.
//

import SwiftUI

public struct TERectangleView2D : View {

    let viewModel: TERectangle2D
    public init(viewModel: TERectangle2D) {
        self.viewModel = viewModel
    }
    
    public func getViewModel() -> TEComponent2D? {
        viewModel
    }
    
    public var body: some View {
        Rectangle()
            .fill(Color.blue)
    }
}
