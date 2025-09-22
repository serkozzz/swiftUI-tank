
//
//  Untitled.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 21.09.2025.
//
import Foundation

class SceneNode: Identifiable {
    
    private(set) var components: [Component] = []
    var transform: Matrix
    
    var position: SIMD2<Float> {
        SIMD2<Float> (self.transform.columns.2.x, self.transform.columns.2.y)
    }
//    var cgPosition: CGPoint {
//        CGPoint(x: Double(self.transform.columns.2.x), y: Double(self.transform.columns.2.y))
//    }
    
    init(transform: Matrix, geometryObject: GeometryObject? = nil) {
        self.transform = transform
        if let go = geometryObject {
            self.components.append(go)
        }

    }
    
    init(position: SIMD2<Float>, geometryObject: GeometryObject? = nil) {
        self.transform = Matrix.init(diagonal: .one)
        self.transform.columns.2.x = position.x
        self.transform.columns.2.y = position.y
        if let go = geometryObject {
            self.components.append(go)
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
