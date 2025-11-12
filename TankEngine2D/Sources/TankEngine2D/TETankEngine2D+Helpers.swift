//
//  TETankEngine2D+Helpers.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 12.11.2025.
//

public extension TETankEngine2D {
    static func findWith(tag: String) -> TESceneNode2D? {
        TETankEngine2D.shared.scene.rootNode.getNodeBy(tag: tag)
    }
}
