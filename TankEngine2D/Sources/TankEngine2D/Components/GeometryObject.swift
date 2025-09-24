//
//  SceneObject.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 21.09.2025.
//

import SwiftUI



public enum GeometryObjectType {
    case tank
    case bullet
    case `static`
    case artillery
}

public class GeometryObject: Component {
    public let type: GeometryObjectType
    public let boundingBox: CGSize
    public init(_ type: GeometryObjectType, boundingBox: CGSize) {
        self.type = type
        self.boundingBox = boundingBox
    }
}
