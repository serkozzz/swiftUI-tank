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
    public var displayName: String { name ?? tag ?? String(id.uuidString.prefix(8)) }
    public var tag: String?
    public var name: String?
    
    public private(set) weak var parent: TESceneNode2D?
    @Published public private(set) var children: [TESceneNode2D] = []
    @Published public private(set) var components: [TEComponent2D] = []
    
    public var visualComponents: [any TEVisualComponent2D] { components.compactMap { $0 as? (any TEVisualComponent2D) } }
    
    @Published public private(set) var transform: TETransform2D {
        didSet { subscribeToLocalTransform(); updateWorldTransform() }
    }

    public var worldTransform: TETransform2D {  _cachedWorldTransform }
    @Published private var _cachedWorldTransform: TETransform2D { didSet { subscribeToWorldTransform() } }
    private var worldTransformSubscription: Set<AnyCancellable> = []
    private var localTransformSubscription: Set<AnyCancellable> = []
    private var componentPropsSubscriptions: [UUID: [AnyCancellable]] = [:]
    
    
    weak var scene: TEScene2D? {
        didSet {
            for child in children {
                child.scene = scene
            }
        }
    }
    
    public init(transform: TETransform2D, componentType: TEComponent2D.Type? = nil, name: String? = nil, tag: String? = nil) {
        self.id = UUID()
        self.transform = transform
        self.name = name
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
    
    private func subscribeToComponentProps(component: TEComponent2D) {
       
        componentPropsSubscriptions.removeAll()
        let sizeSubscription = component.$size.sink { [self] newValue in
            objectWillChange.send()
        }

        componentPropsSubscriptions[component.id] = [sizeSubscription]
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
        

        try c.encode(TENodeComponentsCoder().encodeComponents(components), forKey: .components)    }
    
    public func restoreParent(parent: TESceneNode2D) {
        self.parent = parent
    }
}


extension TESceneNode2D {
    
    public convenience init(position: SIMD2<Float>, componentType: TEComponent2D.Type? = nil,
                            name: String? = nil, tag: String? = nil) {
        let transform = TETransform2D(position: position)
        self.init(transform: transform, componentType: componentType, name: name, tag: tag)
    }

    
    public convenience init?(transform: TETransform2D, componentTypeStr: String? = nil, name: String? = nil, tag: String? = nil) {
        var componentType: TEComponent2D.Type?
        if let componentTypeStr {
            TELogger2D.error("TEComponent2D not found: \(componentTypeStr)")
            componentType = TEComponentsRegister2D.shared.getTypeBy(componentTypeStr)
            return nil
        }
        self.init(transform: transform, componentType: componentType, name: name, tag: tag)

    }
}

extension TESceneNode2D {
    
    @discardableResult
    public func attachComponent<C : TEComponent2D>(_ componentType: TEComponent2D.Type) -> C {
        let component = componentType.init()
        subscribeToComponentProps(component: component)
        components.append(component)
        component.assignOwner(self)
        if let scene  {
            scene.teScene2D(didAttachComponent: component, to: self)
        }
        return component as! C
    }
    
    @discardableResult
    public func attachComponent(_ componentTypeStr: String) -> TEComponent2D? {
        guard let type = TEComponentsRegister2D.shared.getTypeBy(componentTypeStr) else { return nil }
        return self.attachComponent(type)
    }
    
    public func moveComponent(src: Int, dst: Int) {
        precondition(src >= 0 && src < components.count, "src out of range")
        precondition(dst >= 0 && dst <= components.count, "dst out of range")

        let component = components.remove(at: src)
        if dst > components.count {
            //вставка в конец
            components.append(component)
        } else {
            components.insert(component, at: dst)
        }
    }
    
    public func detachComponent(_ componentID: UUID) {
        guard let index = components.firstIndex(where: { $0.id == componentID }) else { return }
        
        componentPropsSubscriptions.removeValue(forKey: componentID)
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

    public func getNodeBy(id: UUID) -> TESceneNode2D? {
        findFirstInSubtree() { id == $0.id }
    }
    
    public func getNodeBy(tag: String?) -> TESceneNode2D? {
        findFirstInSubtree() { tag == $0.tag }
    }
    
    public func getNodesBy(tag: String?) -> [TESceneNode2D] {
        var result: [TESceneNode2D] = []
        foreachInSubtree() { node in
            if tag == node.tag { result.append(node) }
        }
        return result
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
    
    public func findFirstInSubtree(where predicate: (TESceneNode2D) -> Bool) -> TESceneNode2D? {
        if predicate(self) { return self }
        
        for child in self.children {
            if let node = child.findFirstInSubtree(where: predicate) { return node }
        }
        return nil
    }
    
    public var colliders: [TECollider2D] {  getComponents(TECollider2D.self) }
    
    public var collider: TECollider2D? {  getComponents(TECollider2D.self).first }
}

extension TESceneNode2D: Equatable {
    
    nonisolated public static func == (lhs: TESceneNode2D, rhs: TESceneNode2D) -> Bool {
        lhs === rhs
    }
}
