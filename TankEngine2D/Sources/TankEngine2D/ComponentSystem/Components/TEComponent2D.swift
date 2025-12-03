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
    // Базовая реализация: ничего не кодируем
    open func printSerializableProperties() {}
    open func encodeSerializableProperties() -> [String : String] { return [:] }
    open func decodeSerializableProperties(_ dict: [String : String]) { }
    open func setSerializableValue(for propertyName: String, from jsonString: String) { }
    
    public func allTEComponentRefs() -> [String: TEComponent2D?] {
        var result = [String: TEComponent2D?] ()
        
        Mirror.propsForeach(self) { prop in
            guard isPropertyTEComponent2DType(prop.value) else { return }
            guard let propName = prop.label else { return }
            let componentRef = prop.value as? TEComponent2D
            result[propName] = componentRef
        }
        return result
    }
}

private func unwrapOptionalType(_ type: Any.Type) -> Any.Type {
    if let optionalProtocol = type as? any AnyOptionalProtocol.Type {
        return optionalProtocol.wrappedType
    }
    return type
}

// Протокол для получения wrappedType у Optional через типовую акробатику
private protocol AnyOptionalProtocol {
    static var wrappedType: Any.Type { get }
}

extension Optional: AnyOptionalProtocol {
    static var wrappedType: Any.Type { Wrapped.self }
}

private func isPropertyTEComponent2DType(_ value: Any) -> Bool {
    let valueType: Any.Type = type(of: value)
    let unwrapped = unwrapOptionalType(valueType)
    // Проверяем подтипность на уровне метатипов
    return (unwrapped is TEComponent2D.Type) || (unwrapped as? TEComponent2D.Type != nil)
}
