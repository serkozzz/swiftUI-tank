//
//  BuildingView.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 29.09.2025.
//

import SwiftUI
import TankEngine2D

struct BuildingView: View {
    @ObservedObject var model: Building
    var id = UUID()
    

    var body: some View {
        ZStack {
            Rectangle()
                .stroke(.black)
            ForEach(0..<model.floorsNumber, id: \Int.self) { i in
                Rectangle()
                    .stroke(.black).fill(.white).offset(x: CGFloat(5 * i), y: CGFloat(5 * i))
            }
        }
    
    }
}

extension BuildingView: TEView2D {
    var boundingBox: CGSize {
        model.boundingBox
    }
    
    init(viewModel: TankEngine2D.TEComponent2D?) {
        let building = viewModel as! Building
        self._model = ObservedObject(initialValue: building)
    }
    
    func getViewModel() -> TEComponent2D? {
        model
    }
}



#Preview {
    @Previewable @State var building = Building(floorsNumber: 5)
    BuildingView(viewModel: building)
        .frame(width: 200, height: 100)
}
