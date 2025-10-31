//
//  Component.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 22.09.2025.
//

import SwiftUI
import Combine
import SaveKVC

@MainActor
open class TEComponent2D: ObservableObject, Equatable {
    
    private(set) var id = UUID()
    public private(set) weak var owner: TESceneNode2D?
    
    var isStarted: Bool = false
    private var cancelables: Set<AnyCancellable> = []
    
    public var transform: TETransform2D? {
        owner?.transform
    }
    
    public var worldTransform: TETransform2D? {
        owner?.worldTransform
    }
    
    public required init() {
        
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


// MARK: - Encoding/Decoding
extension TEComponent2D {
   
    func encodedData() -> [String: Any] {
        var dict: [String: Any] = [:]
        
        var current: Mirror? = Mirror(reflecting: self)
        while let mirror = current {
            for child in mirror.children {
                guard let key = child.label else { continue }
                if dict[key] == nil {
                    // Берём значение через KVC, чтобы фактически попадали только хранимые KVC-совместимые свойства

                    let kvcValue = SafeKVC.value(forKey: key, of: self)
                    if let v = kvcValue {
                        dict[key] = v
                    } else {
                        // Если KVC недоступна — можно было бы fallback на Mirror, но вы хотите только хранимые
                        // dict[key] = child.value
                    }
                }
            }
            current = mirror.superclassMirror
        }
        return dict
//        do {
//            let data = try JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted])
//            return data
//        } catch {
//            print("JSONSerialization error: \(error)")
//            return nil
//        }
    }
    
    // MARK: - Decoding (apply to existing instance)
    
    /// Применяет значения из JSON к уже существующему объекту.
    /// Это "апдейт", а не создание, поэтому метод назван соответствующе.
    private func applyDecodedValues(from dict: [String: Any]) {        
        // Собираем ключи свойств (включая суперклассы)
        var keys: Set<String> = []
        var mirrors: [Mirror] = []
        var current: Mirror? = Mirror(reflecting: self)
        while let m = current {
            mirrors.append(m)
            current = m.superclassMirror
        }
        for mirror in mirrors {
            for child in mirror.children {
                if let key = child.label {
                    keys.insert(key)
                }
            }
        }
        
        // Устанавливаем только известные свойства
        for key in keys {
            guard let rawValue = dict[key] else { continue }
            
            // Минимально необходимая нормализация для KVC:
            // - NSNull -> nil (важно для опционалов)
            // - остальное передаём как есть (String пробриджится в NSString, числа уже NSNumber)
            let normalized: Any?
            if rawValue is NSNull {
                normalized = nil
            } else {
                normalized = rawValue
            }
            
            _ = SafeKVC.setValue(normalized, forKey: key, of: self)
        }
    }
    
    // MARK: - Factory decode (create new instance)
    
    /// Создаёт новый экземпляр и применяет к нему данные из JSON.
    /// Такой API ближе к привычному Decodable.
    static func decoded(from dict: [String: Any]) -> Self? {
        let obj = self.init()
        obj.applyDecodedValues(from: dict)
        return obj
    }
}
