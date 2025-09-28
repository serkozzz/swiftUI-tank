//
//  BuildingView.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 29.09.2025.
//

import SwiftUI


struct BuildingView: View {
    @ObservedObject var building: Building
    
    init(_ building: Building) {
        self.building = building
    }
    var body: some View {
        ZStack {
            Rectangle()
                .stroke(.black)
            ForEach(0..<building.floorsNumber, id: \Int.self) { i in
                Rectangle()
                    .stroke(.black).fill(.white).offset(x: CGFloat(5 * i), y: CGFloat(5 * i))
            }
        }
    
    }
}

#Preview {
    @Previewable @State var building = Building(floorsNumber: 5)
    BuildingView(building)
        .frame(width: 200, height: 100)
}
