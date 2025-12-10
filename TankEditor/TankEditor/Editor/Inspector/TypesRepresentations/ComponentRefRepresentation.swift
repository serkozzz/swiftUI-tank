//
//  ComponentRefRepresentation.swift
//  TankEditor
//
//  Created by Sergey Kozlov on 10.12.2025.
//

import SwiftUI
import TankEngine2D

struct ComponentRefRepresentation : View {
    var viewModel: PropRefViewModel
    
    var body: some View {
//        if let ref {
//            Text("*")
//        }
//        else {
//            Text("nil")
//        }
        Text("nil")
            .dropDestination(for: SceneNodeTransferable.self) { items,session in
                let nodeTransferable = items.first!
                viewModel.handleDrop(nodeID: nodeTransferable.sceneNodeID)
            }
    }
}
