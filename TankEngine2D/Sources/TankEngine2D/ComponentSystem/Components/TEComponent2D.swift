//
//  Component.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 22.09.2025.
//

import SwiftUI
import Combine
import SaveKVC

@objcMembers
@MainActor
open class TEComponent2D: NSObject, ObservableObject {
    
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
    
    public override required init() {
        
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
                
                // 1) Пропускаем backing @Published (_property)
                if key.hasPrefix("_") { continue }
                
                // 2) Пропускаем сами Published<...> (если такие попадутся в иерархии)
                if isPublishedWrapper(child.value) { continue }
                
                if dict[key] == nil {
                    // Берём значение через KVC только для KVC‑совместимых свойств
                    let kvcValue = SafeKVC.value(forKey: key, of: self)
                    if let v = kvcValue {
                        dict[key] = v
                    } else {
                        // Published и не‑KVC свойства игнорируем по умолчанию.
                        // Возможность ручного добавления ниже:
                    }
                }
            }
            current = mirror.superclassMirror
        }
        
        return dict
    }
    

    
    // MARK: - Decoding (apply to existing instance)
    
    /// Применяет значения из JSON к уже существующему объекту.
    /// Это "апдейт", а не создание, поэтому метод назван соответствующе.
    private func applyDecodedValues(from dict: [String: Any]) {
        // Сначала даём шанс подклассу обработать свои специальные поля (например, @Published)
        if customizeDecoding(from: dict) {
            // подкласс мог "поглотить" часть ключей, это ок
        }
        
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
            // 1) Пропускаем backing @Published (_property)
            if key.hasPrefix("_") { continue }
            
            // 2) Пропускаем Published<...> как таковые
            if let value = SafeKVC.value(forKey: key, of: self),
               isPublishedWrapper(value) {
                continue
            }
            
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
    
    /// Хук для ручной декодировки (например, записать значения в @Published wrappedValue).
    /// Верните true, если вы обработали нужные ключи (необязательно удалять их из словаря).
    @objc open func customizeDecoding(from dict: [String: Any]) -> Bool {
        // По умолчанию — ничего не делаем
        return false
    }
    
    // MARK: - Factory decode (create new instance)
    
    /// Создаёт новый экземпляр и применяет к нему данные из JSON.
    /// Такой API ближе к привычному Decodable.
    static func decoded(from dict: [String: Any]) -> Self? { //covariant return
        let obj = self.init()
        obj.applyDecodedValues(from: dict)
        return obj
    }
    
    // MARK: - Helpers
    
    // Определение Published<Wrapped> без generic-интроспекции: проверяем тип по имени
    private func isPublishedWrapper(_ value: Any) -> Bool {
        let mirror = Mirror(reflecting: value)
        return String(describing: mirror.subjectType).starts(with: "Published<")
    }
}
