//
//  SceneNodeTransferable.swift
//  TankEditor
//
//  Created by Sergey Kozlov on 10.12.2025.
//
import SwiftUI
import TankEngine2D
import UniformTypeIdentifiers


struct SceneNodeTransferable: Codable, Transferable {
    let sceneNodeID: UUID
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(contentType: .data) { nodeTransferable in
            try JSONEncoder().encode(nodeTransferable.sceneNodeID)
        } importing: { data in
            let id = try JSONDecoder().decode(UUID.self, from: data)
            return SceneNodeTransferable(sceneNodeID: id)
        }
    }
}
