//
//  Mirror.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 05.11.2025.
//

import SwiftUI

public extension Mirror {
    static func propsForeach(_ subject: Any, action: (Mirror.Child) -> ())  {
        var current: Mirror? = Mirror(reflecting: subject)
        while let mirror = current {
            for child in mirror.children {
                action(child)
            }
            current = mirror.superclassMirror
        }
    }
    
    static func getPropType(_ owner: Any, propName: String) -> Any.Type? {
        var result: Any.Type?

        
        Mirror.propsForeach(owner) { prop in
            if prop.label == "_" + propName {
                if let published = prop.value as? AnyPublished {
                    result = published.innerType()
                }
            }
            if prop.label == propName {
                result = type(of: prop.value)
            }
        }
        return result
    }
}


// Протокол для получения wrappedType у Optional через типовую акробатику
private protocol AnyPublished {
    func innerType() -> Any.Type?
}
extension Published: AnyPublished {
    func innerType() -> Any.Type? {
        let mirror = Mirror(reflecting: self)

        for child in mirror.children {
            guard let label = child.label else { continue }
            // Published<T> всегда содержит T в поле с именем:
            // "storage", "_value", "wrappedValue", "value"
            if label.contains("storage") {
                let storageMirror = Mirror(reflecting: child.value)
                for child in storageMirror.children {
                    if let valueLabel = child.label,
                       valueLabel.contains("value") {
                        return type(of: child.value)   // ← здесь мы наконец получаем Bool.self, Float.self etc.
                    }
                }
            }
        }

        return nil
    }
}
