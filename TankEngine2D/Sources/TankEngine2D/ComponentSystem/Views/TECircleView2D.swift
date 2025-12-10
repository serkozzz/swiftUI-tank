//
//  TERectangleView2D.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 25.11.2025.
//

import SwiftUI

public struct TECircleView2D : TEView2D {
    public var id: UUID
    let viewModel: TECircle2D
    
    public var boundingBox: CGSize {
        viewModel.size
    }
    
    public init(viewModel: TEComponent2D?) {
        id = UUID()
        self.viewModel = viewModel as! TECircle2D
    }
    
    public func getViewModel() -> TEComponent2D? {
        viewModel
    }
    
    public var body: some View {
        Rectangle()
            .fill(Color.blue)
    }
}
