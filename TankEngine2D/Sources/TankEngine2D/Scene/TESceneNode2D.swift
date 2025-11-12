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
    public var name: String { tag ?? String(id.uuidString.prefix(8)) }
    public var tag: String?
    
    public private(set) weak var parent: TESceneNode2D?
    @Published public private(set) var children: [TESceneNode2D] = []
    @Published public private(set) var components: [TEComponent2D] = []
    public internal(set) var views: [any TEView2D] = []
    
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
    
    public init(transform: TETransform2D, viewType: any TEView2D.Type, viewModelType: TEComponent2D.Type? = nil, debugName: String? = nil, tag: String? = nil) {
        self.id = UUID()
        self.transform = transform
        _cachedWorldTransform = transform
        subscribeToLocalTransform()
        var vm: (TEComponent2D)?
        if let viewModelType {
            vm = attachComponent(viewModelType)
        }
        attachView(viewType, withViewModel: vm)
        self.tag = tag
    }
    
    public init(transform: TETransform2D, componentType: TEComponent2D.Type? = nil, debugName: String? = nil, tag: String? = nil) {
        self.id = UUID()
        self.transform = transform
        _cachedWorldTransform = transform
        subscribeToLocalTransform()
        
        if let componentType {
            _ = attachComponent(componentType)
        }

        self.tag = tag
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
        case transform, children, components, views, debugName, id, tag
    }
    
    public required init(from decoder: Decoder) throws {

        let c = try decoder.container(keyedBy: CodingKeys.self)
        let transform = try c.decode(TETransform2D.self, forKey: .transform)
        self.transform = transform
        _cachedWorldTransform = transform
        
        children = try c.decode([TESceneNode2D].self, forKey: .children)
        tag =  try c.decode(String?.self, forKey: .tag)
        id = try c.decode(UUID.self, forKey: .id)
        
        let sceneAssembler = decoder.userInfo[.sceneAssembler] as! TESceneAssembler
        let componentDTOs = try c.decode([TEComponentDTO].self, forKey: .components)
        TENodeComponentsCoder().restoreComponents(componentDTOs, for: self, sceneAssembler: sceneAssembler)
        
        let viewsDTOs = try c.decode([TEViewDTO].self, forKey: .views)
        sceneAssembler.addViewBlueprints(viewsDTOs.map { TEView2DBlueprint(dto: $0, sceneNode: self)})
        
        subscribeToLocalTransform()
        for child in children {
            child.parent = self
        }
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(transform, forKey: .transform)
        try c.encode(children, forKey: .children)
        try c.encode(tag, forKey: .tag)
        try c.encode(id, forKey: .id)
        

        try c.encode(TENodeComponentsCoder().encodeComponents(components), forKey: .components)
        try c.encode(TENodeViewsCoder().encodeViews(views), forKey: .views)
    }
    
    public func restoreParent(parent: TESceneNode2D) {
        self.parent = parent
    }
}


extension TESceneNode2D {
    
    public convenience init(position: SIMD2<Float>, componentType: TEComponent2D.Type? = nil,
                            debugName: String? = nil, tag: String? = nil) {
        let transform = TETransform2D(position: position)
        self.init(transform: transform, componentType: componentType, debugName: debugName, tag: tag)
    }
    
    public convenience init(position: SIMD2<Float>, viewType: any TEView2D.Type, viewModelType: TEComponent2D.Type? = nil,
                            debugName: String? = nil, tag: String? = nil) {
        let transform = TETransform2D(position: position)
        self.init(transform: transform, viewType: viewType, viewModelType: viewModelType, debugName: debugName, tag: tag)
    }
}

extension TESceneNode2D {
    
    @discardableResult
    public func attachComponent(_ componentType: TEComponent2D.Type) -> TEComponent2D {
        let component = componentType.init()
        
        components.append(component)
        component.assignOwner(self)
        if let scene  {
            scene.teScene2D(didAttachComponent: component, to: self)
        }
        return component
    }
    
    public func detachComponent(_ componentID: UUID) {
        guard let index = components.firstIndex(where: { $0.id == componentID }) else { return }
        
        if let scene {
            scene.teScene2D(willDetachComponent: components[index], from: self)
        }
        let detached = components.remove(at: index)
        detached.assignOwner(nil)
    }
    
    public func attachView<V: TEView2D>(_ viewType: V.Type, withViewModel vm: TEComponent2D? = nil) {
        let view = V.init(viewModel: vm)
        views.append(view)
    }
    
    ///only for decode, not for public API
    internal func attachView(_ view: any TEView2D) {
        views.append(view)
    }
    public func detachView(_ viewID: UUID) {
        views.removeAll(where: { $0.id  == viewID })
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
    
    func getNodeBy(tag: String?) -> TESceneNode2D? {
        if tag == self.tag { return self }
        
        for child in children {
            if let sceneNode = child.getNodeBy(tag: tag) {
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
    
    public func foreachInSubtree(action: (TESceneNode2D) -> Void) {
        for child in self.children {
            child.foreachInSubtree(action: action)
        }
        action(self)
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
