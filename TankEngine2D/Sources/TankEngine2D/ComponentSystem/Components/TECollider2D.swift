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
    
    private(set) var shape: TECollider2DShape
    
    required init() {
        shape = .geometry
        super.init()
    }

    public var boundingBox: CGSize {
        switch shape {
        case .geometry:
            let view = self.owner?.view
            TEAssert.precondition(view != nil, "Geometry object is not set for the collider with shape.geometry")
            return view!.boundingBox
        case .customBoundingBox(let bb):
            return bb
        }
    }
}
