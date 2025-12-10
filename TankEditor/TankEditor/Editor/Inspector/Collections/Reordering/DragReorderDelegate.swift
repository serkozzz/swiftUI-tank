//
//  DragReorderDelegate.swift
//  TankEditor
//
//  Created by Sergey Kozlov on 09.12.2025.
//

import SwiftUI
import TankEngine2D
import UniformTypeIdentifiers


struct DragReorderDelegate: DropDelegate {
    let item: TEComponent2D
    let currentIndex: Int
    let moveAction: (UUID, Int) -> Void
    @Binding var dragState: DragState
    
    func dropEntered(info: DropInfo) {
        
        dragState.isDragOverCollection = true
        guard let draggedID = dragState.draggedItemID else { return }
        print("dropEntered")
        moveAction(draggedID, currentIndex)
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        let providers = info.itemProviders(for: [UTType.componentDrag])
        if let provider = providers.first {
            provider.loadDataRepresentation(forTypeIdentifier: UTType.text.identifier) { data, error in
                // можно ничего не делать
            }
        }
        dragState.reset()
        return true
    }
    
    func dropExited(info: DropInfo) {
        dragState.isDragOverCollection = false
    }
}
