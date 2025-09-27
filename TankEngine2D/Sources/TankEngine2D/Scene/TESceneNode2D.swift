
//
//  Untitled.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 21.09.2025.
//
import Foundation
import Combine

public class TESceneNode2D: ObservableObject, Identifiable {
    
    @Published public private(set) var components: [TEComponent2D] = []
    @Published public private(set) var transform: TETransform2D
    
    private var cancellables: Set<AnyCancellable> = []
    
    public init(transform: TETransform2D, geometryObject: TEGeometryObject2D? = nil) {
        self.transform = transform
        if let go = geometryObject {
            attachComponent(go)
        }
        subscribeToTransform()
    }
    
    
    public init(position: SIMD2<Float>, component: TEComponent2D? = nil) {
        self.transform = TETransform2D(position: position)
        if let component = component {
            attachComponent(component)
        }
        subscribeToTransform()
    }
    
    private func subscribeToTransform() {
        self.$transform.sink { [unowned self] _ in
            self.objectWillChange.send()
        }.store(in: &cancellables)
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
