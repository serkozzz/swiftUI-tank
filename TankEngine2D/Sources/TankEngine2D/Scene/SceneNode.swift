
//
//  Untitled.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 21.09.2025.
//
import Foundation

public class SceneNode: ObservableObject, Identifiable {
    
    public private(set) var components: [Component] = []
    @Published public private(set) var transform: Transform
    
    
    public init(transform: Transform, geometryObject: GeometryObject? = nil) {
        self.transform = transform
        if let go = geometryObject {
            attachComponent(go)
        }

    }
    
    
    public init(position: SIMD2<Float>, component: Component? = nil) {
        self.transform = Transform(position: position)
        if let component = component {
            attachComponent(component)
        }
    }
}

extension SceneNode {
    
    public func attachComponent(_ component: Component) {
        components.append(component)
        component.assignOwner(self)
    }
    
    public func detachComponent(_ component: Component) {
        guard let index = components.firstIndex(of: component) else { return }
        let detached = components.remove(at: index)
        detached.assignOwner(nil)
    }
}

extension SceneNode {
    public func getComponents<T: Component>(_ type: T.Type) -> [T] {
        return components.compactMap { $0 as? T }
    }
    
    public var geometryObjects: [GeometryObject] {  getComponents(GeometryObject.self) }
    
    public var geometryObject: GeometryObject? { getComponents(GeometryObject.self).first }
}
