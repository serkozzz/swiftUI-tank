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
    
    public let id: UUID = UUID()
    public var debugName: String?
    public var name: String { debugName ?? String(id.uuidString.prefix(8)) }
    
    public private(set) weak var parent: TESceneNode2D?
    @Published public private(set) var children: [TESceneNode2D] = []
    @Published public private(set) var components: [TEComponent2D] = []
    
    @Published public private(set) var transform: TETransform2D {
        didSet { subscribeToLocalTransform(); updateWorldTransform(); }
    }

    public var worldTransform: TETransform2D {  _cachedWorldTransform }
    @Published private var _cachedWorldTransform: TETransform2D { didSet { subscribeToWorldTransform() } }
    private var worldTransformSubscription: Set<AnyCancellable> = []
    private var localTransformSubscription: Set<AnyCancellable> = []
    
    weak var scene: TEScene2D? {
        didSet {
            for child in children {
                child.scene = scene
            }
        }
    }
    
    public init(transform: TETransform2D, component: TEComponent2D? = nil, debugName: String? = nil) {
        self.transform = transform
        _cachedWorldTransform = transform
        subscribeToLocalTransform()
        
        if let component = component {
            attachComponent(component)
        }

        self.debugName = debugName
    }
    
    private func subscribeToWorldTransform() {
        worldTransformSubscription.removeAll()
        self._cachedWorldTransform.objectWillChange.sink { [unowned self] _ in
            self.objectWillChange.send()
        }.store(in: &worldTransformSubscription)
    }
    
    private func subscribeToLocalTransform() {
        localTransformSubscription.removeAll()
        transform.objectWillChange.sink { [weak self] _ in
            self?.updateWorldTransform()
        }.store(in: &localTransformSubscription)
    }
}


extension TESceneNode2D {
    public convenience init(transform: TETransform2D, geometryObject: TEGeometryObject2D? = nil, debugName: String? = nil) {
        self.init(transform: transform, component: geometryObject, debugName: debugName)
    }
    
    public convenience init(position: SIMD2<Float>, geometryObject: TEGeometryObject2D? = nil, debugName: String? = nil) {
        let transform = TETransform2D(position: position)
        self.init(transform: transform, component: geometryObject, debugName: debugName)
    }

    public convenience init(position: SIMD2<Float>, component: TEComponent2D? = nil, debugName: String? = nil) {
        let transform = TETransform2D(position: position)
        self.init(transform: transform, component: component, debugName: debugName)
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
        node.parent?.removeChild(node)
        
        children.append(node)
        node.parent = self
        
        node.scene = scene
        node.updateWorldTransform()
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
        node.updateWorldTransform()
    }
}


//MARK: worldTransform
extension TESceneNode2D {
    func updateWorldTransform() {
        let parentTransform: TETransform2D = (parent != nil) ? parent!.transform : .identity
        _cachedWorldTransform = parentTransform * transform
        for child in self.children {
            child.updateWorldTransform()
        }
    }
}


extension TESceneNode2D {
    public func getComponents<T: TEComponent2D>(_ type: T.Type) -> [T] {
        return components.compactMap { $0 as? T }
    }
    
    /// search includes self node
    public func getAllComponentsInSubtree<T: TEComponent2D>(_ type: T.Type) -> [T] {
        var result = [T]()
        result += self.components.compactMap { $0 as? T }
        
        for child in children {
            result += child.getAllComponentsInSubtree(type)
        }
        return result
    }
    
    public var geometryObjects: [TEGeometryObject2D] {  getComponents(TEGeometryObject2D.self) }
    
    public var geometryObject: TEGeometryObject2D? { getComponents(TEGeometryObject2D.self).first }
    
    public var colliders: [TECollider2D] {  getComponents(TECollider2D.self) }
    
    public var collidersInSubtree: [TECollider2D] {  getAllComponentsInSubtree(TECollider2D.self) }
    
    public var collider: TECollider2D? {  getComponents(TECollider2D.self).first }
}

extension TESceneNode2D: Equatable {
    
    nonisolated public static func == (lhs: TESceneNode2D, rhs: TESceneNode2D) -> Bool {
        lhs === rhs
    }
}
