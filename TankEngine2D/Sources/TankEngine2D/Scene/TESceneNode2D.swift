//
//  Untitled.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 21.09.2025.
//
import Foundation
import Combine

@MainActor
public final class TESceneNode2D: ObservableObject, @MainActor Codable, Identifiable {
    
    public let id: UUID
    public var debugName: String?
    public var name: String { debugName ?? String(id.uuidString.prefix(8)) }
    
    public private(set) weak var parent: TESceneNode2D?
    @Published public private(set) var children: [TESceneNode2D] = []
    @Published public private(set) var components: [TEComponent2D] = []
    public private(set) var views: [any TEView2D] = []
    
    @Published public private(set) var transform: TETransform2D {
        didSet { subscribeToLocalTransform(); updateWorldTransform() }
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
    
    public init(transform: TETransform2D, viewType: any TEView2D.Type, viewModel: TEComponent2D, debugName: String? = nil) {
        self.id = UUID()
        self.transform = transform
        _cachedWorldTransform = transform
        subscribeToLocalTransform()
        attachComponent(viewModel)
        attachView(viewType, withViewModel: viewModel)
        self.debugName = debugName
    }
    
    public init(transform: TETransform2D, component: TEComponent2D? = nil, debugName: String? = nil) {
        self.id = UUID()
        self.transform = transform
        _cachedWorldTransform = transform
        subscribeToLocalTransform()
        
        if let component {
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
        // It is very important to subscribe exactly to didChange instead of objectWillChange
        // because objectWillChange emits before real property set
        transform.didChange
            .sink { [weak self] in
                self?.updateWorldTransform()
            }
            .store(in: &localTransformSubscription)
    }
    
    
    //MARK: Codable
    enum CodingKeys: CodingKey {
        case transform, children, components, debugName, id
    }
    
    public required init(from decoder: Decoder) throws {

        let c = try decoder.container(keyedBy: CodingKeys.self)
        let transform = try c.decode(TETransform2D.self, forKey: .transform)
        self.transform = transform
        _cachedWorldTransform = transform
        
        children = try c.decode([TESceneNode2D].self, forKey: .children)
        debugName = try c.decode(String.self, forKey: .debugName)
        
        if debugName == "PlayerController" {
            var a = 10
        }
        id = try c.decode(UUID.self, forKey: .id)
        
        let linker = decoder.userInfo[.componentsLinker2D] as! TEComponentsLinker2D
        let componentRepresentations = try c.decode([TEEncodedComponent2D].self, forKey: .components)
        self.components = TEComponentsSerializer2D().restoreComponents(componentRepresentations, linker: linker)
        subscribeToLocalTransform()
    }

    public func encode(to encoder: Encoder) throws {
        if debugName == "PlayerController" {
            var a = 10
        }
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(transform, forKey: .transform)
        try c.encode(children, forKey: .children)
        try c.encode(debugName, forKey: .debugName)
        try c.encode(id, forKey: .id)

        try c.encode(TEComponentsSerializer2D().encodeComponents(components), forKey: .components)
    }
    
    public func restoreParent(parent: TESceneNode2D) {
        self.parent = parent
    }
}


extension TESceneNode2D {
    
    public convenience init(position: SIMD2<Float>, component: TEComponent2D? = nil, debugName: String? = nil) {
        let transform = TETransform2D(position: position)
        self.init(transform: transform, component: component, debugName: debugName)
    }
    
    public convenience init(position: SIMD2<Float>, viewType: any TEView2D.Type, viewModel: TEComponent2D, debugName: String? = nil) {
        let transform = TETransform2D(position: position)
        self.init(transform: transform, viewType: viewType, viewModel: viewModel, debugName: debugName)
    }
}

extension TESceneNode2D {
    
    public func attachComponent(_ component: TEComponent2D) {
        TEAssert.precondition(component.owner == nil, "forbidden to attach component that is already attached")
        TEAssert.precondition(!component.isStarted, "forbidden to reattach components")
        
        components.append(component)
        component.assignOwner(self)
        if let scene  {
            scene.teScene2D(didAttachComponent: component, to: self)
        }
    }
    
    public func attachView<V: TEView2D>(_ viewType: V.Type, withViewModel vm: TEComponent2D? = nil) {
        let view = V.init(viewModel: vm)
        views.append(view)
    }
    
//    public func detachView(_ viewID: UUID) {
//        views.removeAll(where: { $0.id  == viewID })
//    }
    
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
        let parentTransform: TETransform2D = (parent != nil) ? parent!.worldTransform : .identity
        _cachedWorldTransform = parentTransform * transform
        for child in self.children {
            child.updateWorldTransform()
        }
    }
}


extension TESceneNode2D {

    func getNodeBy(id: UUID) -> TESceneNode2D? {
        if id == self.id { return self }
        
        for child in children {
            if let sceneNode = child.getNodeBy(id: id) {
                return sceneNode
            }
        }
        return nil
    }
    
    public func getComponent<T: TEComponent2D>(_ type: T.Type) -> T? {
        return getComponents(T.self).first
    }

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
    
    public var view: (any TEView2D)? { views.first }
    
    public var colliders: [TECollider2D] {  getComponents(TECollider2D.self) }
    
    public var collider: TECollider2D? {  getComponents(TECollider2D.self).first }
}

extension TESceneNode2D: Equatable {
    
    nonisolated public static func == (lhs: TESceneNode2D, rhs: TESceneNode2D) -> Bool {
        lhs === rhs
    }
}
