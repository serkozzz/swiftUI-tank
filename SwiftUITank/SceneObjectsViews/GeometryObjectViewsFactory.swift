//
//  GeometryObjectViewsFactory.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 21.09.2025.
//

import SwiftUI
import TankEngine2D

class GeometryObjectViewsFactory {

    static func getView(for type: ) -> AnyView {
        let view: any View
        switch type {
            
        case .tank:
            //TankView()
            view = EmptyView()
        case .bullet:
            view = EmptyView()
        case .static:
            view = StaticObject()
        case .artillery:
            view = ArtilleryView()
        }
        return AnyView(view)
    }
}
