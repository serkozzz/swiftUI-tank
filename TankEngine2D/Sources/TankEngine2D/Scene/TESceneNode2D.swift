
//
//  Untitled.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 21.09.2025.
//
import Foundation

public class TESceneNode2D: ObservableObject, Identifiable {
    
    public private(set) var components: [TEComponent2D] = []
    @Published public private(set) var transform: TETransform2D
    
    
    public init(transform: TETransform2D, geometryObject: TEGeometryObject2D? = nil) {
        self.transform = transform
        if let go = geometryObject {
            attachComponent(go)
        }

    }
    
    
    public init(position: SIMD2<Float>, component: TEComponent2D? = nil) {
        self.transform = TETransform2D(position: position)
        if let component = component {
            attachComponent(component)
        }
    }
}

extension TESceneNode2D {
    
    public func attachComponent(_ component: TEComponent2D) {
        components.append(component)
        component.assignOwner(self)
    }
    
    public func detachComponent(_ component: TEComponent2D) {
        guard let index = components.firstIndex(of: component) else { return }
        let detached = components.remove(at: index)
        detached.assignOwner(nil)
    }
}

extension TESceneNode2D {
    public func getComponents<T: TEComponent2D>(_ type: T.Type) -> [T] {
        return components.compactMap { $0 as? T }
    }
    
    public var geometryObjects: [TEGeometryObject2D] {  getComponents(TEGeometryObject2D.self) }
    
    public var geometryObject: TEGeometryObject2D? { getComponents(TEGeometryObject2D.self).first }
}
