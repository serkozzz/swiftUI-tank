//
//  GeometryObjectViewsFactory.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 21.09.2025.
//

import SwiftUI
import TankEngine2D

class GeometryObjectViewsFactory {
    static func createView<T: BaseSceneObject>(for object: T) -> AnyView {
        var view: any View
        if object is Cannon {
            view = ArtilleryView()
        } else if object is Building {
            view = BuildingView()
        } else {
            print("SceneObjectViewsFactory error: unknown object type: \(String(describing: type(of: object)))")
            fatalError()
        }
        return AnyView(view)
    }
}
