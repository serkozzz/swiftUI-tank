//
//  TEMissedComponent2D.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 03.11.2025.
//

import SwiftUI

public struct TEMissedView2D: TEView2D {

    public var body: some View {
        
    }
    
    public var boundingBox: CGSize {
        .zero
    }
    
    public init(viewModel: TEComponent2D?) {
        
    }
    
    public func getViewModel() -> TEComponent2D? {
        nil
    }
    
    public var id = UUID()
}
