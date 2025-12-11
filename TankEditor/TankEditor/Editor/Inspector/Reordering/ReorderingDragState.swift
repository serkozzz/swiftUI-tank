//
//  DragState.swift
//  TankEditor
//
//  Created by Sergey Kozlov on 09.12.2025.
//

import Foundation

struct ReorderingDragState {
    var draggedItemID: UUID?
    var isDragOverCollection: Bool = false
    mutating func reset() {
        draggedItemID = nil
        isDragOverCollection = false
    }
}
