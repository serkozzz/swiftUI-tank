//
//  EnemyArtilleryView.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 26.08.2025.
//

import SwiftUI
import TankEngine2D


struct CannonView: View {

    @ObservedObject var model: Cannon
    var id = UUID()
    
    init(_ model: Cannon) {
        self.model = model
    }
    
    var body: some View {
        GeometryReader { geo in
            let cannonSize = geo.size
            Group {
                if (model.destroyed) {
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
                    .rotationEffect(Angle(radians: model.barrelAngleRadians))
                }
            }
            .frame(width: cannonSize.width, height: cannonSize.height)
            .background {
                Rectangle().stroke(.red)
            }
                
        }
    }
}

extension CannonView: TEView2D {
    var boundingBox: CGSize {
        model.boundingBox
    }
    
    init(viewModel: TankEngine2D.TEComponent2D?) {
        let cannon = viewModel as! Cannon
        self._model = ObservedObject(initialValue: cannon)
    }
    
    func getViewModel() -> TankEngine2D.TEComponent2D? {
        model
    }
    
    
}

#Preview {
    CannonView(Cannon())
}
