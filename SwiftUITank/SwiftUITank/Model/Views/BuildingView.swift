//
//  BuildingView.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 29.09.2025.
//

import SwiftUI
import TankEngine2D

struct BuildingView: View {
    @ObservedObject var viewModel: Building

    init(viewModel: Building) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .stroke(.black)
            ForEach(0..<viewModel.floorsNumber, id: \Int.self) { i in
                Rectangle()
                    .stroke(.black).fill(.white).offset(x: CGFloat(5 * i), y: CGFloat(5 * i))
            }
        }
    
    }
}


    




#Preview {
    @Previewable @State var building = Building()
    BuildingView(viewModel: building)
        .frame(width: 200, height: 100)
}
