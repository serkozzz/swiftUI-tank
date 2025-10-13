//
//  TECollision2D.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 02.10.2025.
//

import Foundation

public enum TECollider2DShape : Equatable {
    case geometry
    case customBoundingBox(CGSize)
}

public class TECollider2D: TEComponent2D {
    
    let shape: TECollider2DShape
    
    public init(shape: TECollider2DShape = .geometry) {
        self.shape = shape
    }
    
    public var boundingBox: CGSize {
        switch shape {
        case .geometry:
            let go = self.owner?.geometryObject
            TEAssert.precondition(go != nil, "Geometry object is not set for the collider with shape.geometry")
            return go!.boundingBox
        case .customBoundingBox(let bb):
            return bb
        }
    }
}
