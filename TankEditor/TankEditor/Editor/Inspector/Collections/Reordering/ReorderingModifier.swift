//
//  ReorderingModifier.swift
//  TankEditor
//
//  Created by Sergey Kozlov on 09.12.2025.
//

import SwiftUI
import TankEngine2D
import UniformTypeIdentifiers

struct ReorderingModifier<T : Identifiable>: ViewModifier where T.ID == UUID {
    
    @Binding var dragState: DragState
    var items: [T]
    var item: T
    var index: Int
    var uiTypeIdentifier: String
    var move: (Int, Int) -> Void
    
    func body(content: Content) -> some View {
        content
            .opacity(dragState.draggedItemID == item.id && dragState.isDragOverCollection ? 0.2 : 1.0)
            .onDrag( {
                dragState.draggedItemID = item.id
                let provider = NSItemProvider()
                provider.registerDataRepresentation(forTypeIdentifier: uiTypeIdentifier, visibility: .all) { completion in
                    let data = item.id.uuidString.data(using: .utf8)!
                    completion(data, nil)
                    return nil
                }
                return provider
            })
            .onDrop(of: [uiTypeIdentifier],
                    delegate: DragReorderDelegate(item: item,
                                     currentIndex: index,
                                     moveAction: moveComponent,
                                                   dragState: $dragState)
            )
        
    }
    
    func moveComponent(sourceID: UUID, destIndex: Int) {
        print("moveComponent")
        guard let sourceIndex = items.firstIndex(where: { $0.id == sourceID }) else { return }
        print("sourceIndex = \(sourceIndex), destIndex = \(destIndex)")
        if sourceIndex != destIndex {
            move(sourceIndex, destIndex)
        }
    }
}

extension View {
    func reordering<T: Identifiable>(dragState: Binding<DragState>,
                                     items: [T],
                                     item: T,
                                     index: Int,
                                     uiTypeIdentifier: String,
                                     move: @escaping (Int, Int) -> Void
    ) -> some View where T.ID == UUID {
        self.modifier(ReorderingModifier(dragState: dragState,
                                         items: items,
                                         item: item,
                                         index: index,
                                         uiTypeIdentifier: uiTypeIdentifier,
                                         move: move))
    }
}
