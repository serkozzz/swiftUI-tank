
//
//  Untitled.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 21.09.2025.
//
import Foundation

class SceneNode: ObservableObject, Identifiable {
    
    private(set) var components: [Component] = []
    @Published private(set) var transform: Transform
    
    
    init(transform: Transform, geometryObject: GeometryObject? = nil) {
        self.transform = transform
        if let go = geometryObject {
            attachComponent(go)
        }

    }
    
    
    init(position: SIMD2<Float>, component: Component? = nil) {
        self.transform = Transform(position: position)
        if let component = component {
            attachComponent(component)
        }
    }
}

extension SceneNode {
    
    func attachComponent(_ component: Component) {
        components.append(component)
        component.assignOwner(self)
    }
    
    func detachComponent(_ component: Component) {
        guard let index = components.firstIndex(of: component) else { return }
        let detached = components.remove(at: index)
        detached.assignOwner(nil)
    }
}

extension SceneNode {
    func getComponents<T: Component>(_ type: T.Type) -> [T] {
        return components.compactMap { $0 as? T }
    }
    
    var geometryObjects: [GeometryObject] {  getComponents(GeometryObject.self) }
    
    var geometryObject: GeometryObject? { getComponents(GeometryObject.self).first }
}
