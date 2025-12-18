//
//  EnemyArtilleryView.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 26.08.2025.
//

import SwiftUI
import TankEngine2D


struct CannonView: View {

    @ObservedObject var viewModel: Cannon
    var id = UUID()
    
    init(viewModel: Cannon) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        GeometryReader { geo in
            let cannonSize = geo.size
            Group {
                if (viewModel.destroyed) {
                    Rectangle().fill(.black)
                }
                else {
                    ZStack {
                        Rectangle()
                            .fill(.black)
                            .frame(width:cannonSize.width, height: 2)
                            .offset(x: cannonSize.width/2)
                        
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 5, height: 5)
                            .zIndex(100)
                            .offset(x: cannonSize.width)
                        
                        
                            .background {
                                Rectangle().stroke(.red)
                            }
                    }
                    .rotationEffect(Angle(radians: viewModel.barrelAngleRadians))
                }
            }
            .frame(width: cannonSize.width, height: cannonSize.height)
            .background {
                Rectangle().stroke(.red)
            }
                
        }
    }
}

#Preview {
    CannonView(viewModel: Cannon())
}
