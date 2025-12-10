//
//  ReorderingModifier.swift
//  TankEditor
//
//  Created by Sergey Kozlov on 09.12.2025.
//

import SwiftUI
import TankEngine2D
import UniformTypeIdentifiers

struct ReorderingModifier: ViewModifier {
    
    @Binding var dragState: DragState
    var items: [TEComponent2D]
    var item: TEComponent2D
    var index: Int
    var move: (Int, Int) -> Void
    
    func body(content: Content) -> some View {
        content
            .onDrag( {
                dragState.draggedItemID = item.id
                let provider = NSItemProvider()
                provider.registerDataRepresentation(forTypeIdentifier: UTType.componentDrag.identifier, visibility: .all) { completion in
                    let data = item.id.uuidString.data(using: .utf8)!
                    completion(data, nil)
                    return nil
                }
                return provider
            })
            .onDrop(of: [.componentDrag],
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
    func reordering(dragState: Binding<DragState>,
                    items: [TEComponent2D],
                    item: TEComponent2D,
                    index: Int,
                    move: @escaping (Int, Int) -> Void) -> some View {
        self.modifier(ReorderingModifier(dragState: dragState, items: items, item: item, index: index, move: move))
    }
}
