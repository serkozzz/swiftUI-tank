//
//  SceneObject.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 21.09.2025.
//

import SwiftUI



public class TEGeometryObject2D: TEComponent2D {
    public private(set) var viewToRender: AnyView
    public var boundingBox: CGSize
    public init(_ viewToRender: AnyView, boundingBox: CGSize) {
        self.viewToRender = viewToRender
        self.boundingBox = boundingBox
    }
    
    required init() {
        viewToRender = AnyView(EmptyView())
        boundingBox = .zero
    }
}
