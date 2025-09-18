//
//  EnemyArtilleryView.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 26.08.2025.
//

import SwiftUI

struct EnemyArtilleryView: View {

    let animation = Animation
        .linear(duration: 4)
        .repeatForever(autoreverses: false)
    
    @State var tankSize: CGFloat = 40
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.black)
                .frame(width:tankSize, height: 2)
                .offset(x: tankSize/2)
            
            Circle()
                .fill(Color.accentColor)
                .frame(width: 5, height: 5)
                .zIndex(100)
                .offset(x: tankSize)

            
                .background {
                    Rectangle().stroke(.red)
                }
        }
        .frame(width: tankSize, height: tankSize)
        .background {
            Rectangle().stroke(.red)
        }
    }
}


#Preview {
    EnemyArtilleryView()
}
