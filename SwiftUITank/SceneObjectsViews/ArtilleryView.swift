//
//  EnemyArtilleryView.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 26.08.2025.
//

import SwiftUI

struct ArtilleryView: View {

    let animation = Animation
        .linear(duration: 4)
        .repeatForever(autoreverses: false)
    
    
    var body: some View {
        GeometryReader { geo in
            let tankSize = geo.size
            ZStack {
                Rectangle()
                    .fill(.black)
                    .frame(width:tankSize.width, height: 2)
                    .offset(x: tankSize.width/2)
                
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 5, height: 5)
                    .zIndex(100)
                    .offset(x: tankSize.width)
                
                
                    .background {
                        Rectangle().stroke(.red)
                    }
            }
            .frame(width: tankSize.width, height: tankSize.height)
            .background {
                Rectangle().stroke(.red)
            }
        }
    }
}


#Preview {
    ArtilleryView()
}
