//
//  Untitled.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 21.09.2025.
//
import Foundation
import Combine

@MainActor
public class TESceneNode2D: ObservableObject, Identifiable {
    
    public private(set) weak var parent: TESceneNode2D?
    @Published public private(set) var children: [TESceneNode2D] = []
    @Published public private(set) var components: [TEComponent2D] = []
    @Published public private(set) var transform: TETransform2D
    
    weak var scene: TEScene2D? {
        didSet {
            for child in children {
                child.scene = scene
            }
        }
    }
    
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
        self.transform.objectWillChange.sink { [unowned self] _ in
            self.objectWillChange.send()
        }.store(in: &cancellables)
    }
}

extension TESceneNode2D {
    
    public func attachComponent(_ component: TEComponent2D) {
        // В проде упадёт на precondition; в тестах — перехватится и будет ранний выход.
        TEAssert.precondition(component.owner == nil, "forbidden to attach component that is already attached")
        
        TEAssert.precondition(!component.isStarted, "forbidden to reattach components")
        
        components.append(component)
        component.assignOwner(self)
        if let scene  {
            scene.teScene2D(didAttachComponent: component, to: self)
        }
    }
    
    public func detachComponent(_ component: TEComponent2D) {
        guard let index = components.firstIndex(of: component) else { return }
        
        if let scene {
            scene.teScene2D(willDetachComponent: components[index], from: self)
        }
        let detached = components.remove(at: index)
        detached.assignOwner(nil)
    }
}

extension TESceneNode2D {
    public func addChild(_ node: TESceneNode2D) {
        children.append(node)
        node.parent = self
        node.scene = scene
        if let scene {
            scene.teScene2D(didAddNode: node)
        }
    }
    
    public func removeChild(_ node: TESceneNode2D) {
        guard let index = children.firstIndex(of: node) else { return }
        children.remove(at: index)
        if let scene {
            scene.teScene2D(willRemoveNode: node)
        }
        node.parent = nil
        node.scene = nil
    }
}

extension TESceneNode2D {
    public func getComponents<T: TEComponent2D>(_ type: T.Type) -> [T] {
        return components.compactMap { $0 as? T }
    }
    
    public var geometryObjects: [TEGeometryObject2D] {  getComponents(TEGeometryObject2D.self) }
    
    public var geometryObject: TEGeometryObject2D? { getComponents(TEGeometryObject2D.self).first }
}

extension TESceneNode2D: Equatable {
    
    nonisolated public static func == (lhs: TESceneNode2D, rhs: TESceneNode2D) -> Bool {
        lhs === rhs
    }
}
