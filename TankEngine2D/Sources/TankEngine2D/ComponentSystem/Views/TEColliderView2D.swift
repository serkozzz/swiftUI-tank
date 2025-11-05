//
//  SwiftUIView.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 13.10.2025.
//

import SwiftUI

struct TEColliderView2D: TEView2D {
    
    init(viewModel: TEComponent2D?) {
        model = viewModel as! TECollider2D
    }

    func getViewModel() -> TEComponent2D {
        model
    }
    
   
    var boundingBox: CGSize {
        model.boundingBox
        //viewModel.boundingBox
    }

    var model: TECollider2D
    
    var body: some View {
        Rectangle().stroke(.orange)
    }
}

//#Preview {
//    TEColliderView2D()
//}
