//
//  SwiftUIView.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 13.10.2025.
//

import SwiftUI

struct TEColliderView2D: View {
    var viewModel: TECollider2D
    var id = UUID()
    
    init(viewModel: TECollider2D) {
        self.viewModel = viewModel
    }

    var boundingBox: CGSize {
        viewModel.boundingBox
    }
    
    var body: some View {
        Rectangle().stroke(.orange)
    }
}

//#Preview {
//    TEColliderView2D()
//}
