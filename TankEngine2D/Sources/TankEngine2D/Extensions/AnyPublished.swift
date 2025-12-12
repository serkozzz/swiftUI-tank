//
//  AnyPublished.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 11.12.2025.
//

import Foundation

// Протокол для получения wrappedType у Published через типовую акробатику
protocol AnyPublished {
    func innerType() -> Any.Type
}

extension Published: AnyPublished {
    
    //doesn't work!!! look like sometimes work and sometimes doesn't
    func innerType() -> Any.Type {
        Value.self
    }
}


func unwrapPublishedType(_ owner: Any, propName: String) -> Any.Type? {
    var result: Any.Type?
    Mirror.propsForeach(owner) { prop in
        
        if prop.label == "_rectangle" && propName == "_rectangle" {
            var a = 10
            a += 10
        }
        
        if prop.label == "_" + propName {
            if let published = prop.value as? AnyPublished {
                result = published.innerType()
            }
        }
        if prop.label == propName {
            if let published = prop.value as? AnyPublished {
                result = published.innerType()
            }
            else {
                result = type(of: prop.value)
            }
        }
    }
    return result
}

//
//func unwrapPublishedType(_ owner: Any, propName: String)  -> Any.Type? {
//    var result: Any.Type?
//    Mirror(reflecting: owner).children.forEach { child in
//        guard let name = child.label, name == propName else { return }
//        
//        let value = child.value
//        let valueType = type(of: value)
//        
//        if name == "_rectangle" {
//            var a = 10
//            a += 10
//        }
//        // 🔥 A) Published<TEComponent> ?
//        if let published = value as? AnyPublished,
//           let inner = published.publishedInnerType() {
//            
//            result = inner
//        }
//        else  {
//            result = valueType
//        }
//
//    }
//    return result
//}
