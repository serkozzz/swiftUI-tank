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
    @State private var isTargeted: Bool = false
    
    var body: some View {
        Text(viewModel.valueToShow)
            .frame(maxWidth: .infinity)
            .dropDestination(for: SceneNodeTransferable.self, action: { items, session in
                guard let nodeTransferable = items.first else { return false }
                let nodeID = nodeTransferable.sceneNodeID
                
                if viewModel.canAcceptDrop(nodeID: nodeID) {
                    viewModel.handleDrop(nodeID: nodeID)
                    return true
                }
                return false
            }, isTargeted: { hovering in
                isTargeted = hovering
            })
            .background {
                if isTargeted { Rectangle().stroke(Color.accentColor) } else { Color.clear }
            }
    }
}

