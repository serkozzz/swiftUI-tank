//
//  SceneObject.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 21.09.2025.
//

import SwiftUI



enum GeometryObjectType {
    case tank
    case bullet
    case `static`
    case artillery
}

class GeometryObject {
    let type: GeometryObjectType
    let boundingBox: CGSize
    init(_ type: GeometryObjectType, boundingBox: CGSize) {
        self.type = type
        self.boundingBox = boundingBox
    }
}
