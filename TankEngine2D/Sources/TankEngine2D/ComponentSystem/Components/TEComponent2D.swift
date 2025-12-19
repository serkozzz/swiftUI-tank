//
//  Component.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 22.09.2025.
//

import SwiftUI
import Combine

@objcMembers
@MainActor
open class TEComponent2D: NSObject, ObservableObject, @MainActor Identifiable {
    
    final public internal(set) var id = UUID()
    public private(set) weak var owner: TESceneNode2D?
    @Published var size: CGSize = CGSize(width: 100, height: 100)
    
    var isStarted: Bool = false
    var isAwaked: Bool = false
    
    private var cancelables: Set<AnyCancellable> = []
    
    public var transform: TETransform2D? {
        owner?.transform
    }
    
    public var worldTransform: TETransform2D? {
        owner?.worldTransform
    }
    
    public override required init() {
        
    }
    
    
    open func awake() {
        
    }
    
    /**  Start вызывается ТОЛЬКО ОДИН РАЗ, когда экземпляр впервые попадает в играющую сцену.
     
     Это может произойти в 3-х случаях:
     1. attach к живому узлу
     2. присоединение поддерева с этим узлом к живому дереву (если отсоединили узел и присоединили снова - повторного вызова не будет)
     3. при старте двжика вызывается start() для всех компонентов сцены, с которой движок стартует.
     
     Reattach запрещён после того, как компонент уже был присоединён и/или стартовал. (будет assert/precondition )
     */
    open func start() {
        
    }
    
    final internal func emitAwakeIfNeeded() {
        if (isAwaked) { return }
        isAwaked = true
        awake()
    }
    
    final internal func emitStartIfNeeded() {
        if (isStarted) { return }
        isStarted = true
        start()
    }
    
    open func update(timeFromLastUpdate: TimeInterval) {
    }
    
    
    open func collision(collider: TECollider2D) {
        
    }
    
    internal func assignOwner(_ node: TESceneNode2D?) {
        owner = node
        
    }
    
    nonisolated public static func == (lhs: TEComponent2D, rhs: TEComponent2D) -> Bool {
        return lhs === rhs
    }
}


// MARK: - base implementation, macro will generate overriding methods for derived classes marked @TESerializable
@MainActor
extension TEComponent2D {
    
    open func printSerializableProperties() {
        print("serializable: size =\(self.size)")
    }
    
    open func encodeSerializableProperties() -> [String: String] {
        var dict: [String: String] = [:]
        do {
            var data = try JSONEncoder().encode(self.size)
            if let size = String(data: data, encoding: .utf8) {
                dict["size"] = size
            }
        } catch {
            print("[TESerializable][warning] failed to encode size: \(error)")
        }
        return dict
    }
    
    open func decodeSerializableProperties(_ dict: [String: String]) {
        if let json = dict["size"] {
            setSerializableValue(for: "size", from: json)
        }
    }
    
    open func setSerializableValue(for propertyName: String, from jsonString: String) {
        if propertyName == "size", let data = jsonString.data(using: .utf8 ) {
            if let value = try? JSONDecoder().decode(CGSize.self, from: data) {
                self.size = value
            }
        }
    }
    
    open func allTEComponentRefs() -> [TEComponentRefDTO] { [] }
    
    func isPropTEComponent2DType(propName: String, propValue: Any) -> Bool {
        
        //A) Published<TEComponent> ?
        guard let unwrappedPublishedType = unwrapPublishedType(self, propName: propName) else { return false }
        
        // B) Optional<TEComponent> ?
        // let valueType: Any.Type = type(of: propValue)
        let unwrapped = unwrapOptionalType(unwrappedPublishedType)
        
        return unwrapped is TEComponent2D.Type
    }
}
