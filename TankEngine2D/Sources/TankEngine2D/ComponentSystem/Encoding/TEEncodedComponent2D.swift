//
//  TEComponent2DJSONRepresentation.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 03.11.2025.
//

import Foundation
import SafeKVC

@MainActor
struct TEEncodedComponent2D: @MainActor Codable {
    var className: String
    var properties: [TEEncodedComponent2DProperty]
    
    init(_ component: TEComponent2D) throws {
        self.className = String(reflecting: type(of: component))
        properties = TEEncodedComponent2D.encodedPreviewable(component)
    }
    
    func restoreComponent() -> TEComponent2D {
        let type = TEComponentsRegister2D.shared.registredComponents[className]
        guard let type else { return TEMissedComponent2D() }
    
        let component = type.init()
        restorePreviewableProperties(for: component)
        return component
    }
}



extension TEEncodedComponent2D {
    
    static func encodedPreviewable(_ component: TEComponent2D) -> [TEEncodedComponent2DProperty] {
        var result = [TEEncodedComponent2DProperty]()
        
        var current: Mirror? = Mirror(reflecting: component)
        while let mirror = current {
            for child in mirror.children {
                guard let key = child.label else { continue }
                
                guard let typeName = getTypeNameOfPropertyWith(name: key, of: component) else {
                    continue
                }
                guard typeName.contains("TEPreviewable") else { continue }
                
                guard let (_, propValue) = getValueAndTypeOfPropertyWith(name: key,
                                                                                                 of: component)
                else { continue }
                
                result.append( TEEncodedComponent2DProperty(propertyName: key,
                                                            propertyValue: propValue,
                                                            propertyType: typeName) )
            }
            current = mirror.superclassMirror
        }
        
        return result
    }
    
    private func restorePreviewableProperties(for component: TEComponent2D) {
        
        for property in self.properties {
            // guard let (_, value) = getValueAndTypeOfPropertyWith(name: property.propertyName, of: component)
            //else { continue //new component implementation doesn't contain such property
            //}
            
            guard let value = SafeKVC.value(forKey: property.propertyName, of: component) else { continue }
            
            let previewable = value as! TEPreviewable2DProtocol
            let innerType = previewable.self.valueType
            
            guard let decodedValue = try? decodeHelper(innerType, property.propertyValue)
            else {
//                TELogger2D.print("Could not restore property: \(property.propertyName) of type: \(String(describing: propType))")
                continue
            }
            _ = SafeKVC.setValue(decodedValue, forKey: property.propertyName, of: component)
        
            
        }
        
        func decodeHelper<T: Decodable>(_ type: T.Type, _ data: Data) throws ->  T {
            try JSONDecoder().decode(type, from: data)
        }
        
//        // Собираем ключи свойств (включая суперклассы)
//        var keys: Set<String> = []
//        var mirrors: [Mirror] = []
//        
//        while let m = current {
//            mirrors.append(m)
//            current = m.superclassMirror
//        }
//        for mirror in mirrors {
//            for child in mirror.children {
//                if let key = child.label {
//                    keys.insert(key)
//                }
//            }
//        }
        
//        // Устанавливаем только previewable свойства
//        for key in keys {
//            guard key == "previewable" else { continue }
//            guard let rawValue = dict[key] else { continue }
//            
//            _ = SafeKVC.setValue(normalized, forKey: key, of: self)
//        }
    }
}


private func getTypeNameOfPropertyWith(name: String, of component: TEComponent2D) -> String? {
    guard let value = SafeKVC.value(forKey: name, of: component) else { return nil }
    let type = type(of: value)
    return String(reflecting: type)
}

private func getValueAndTypeOfPropertyWith(name: String, of component: TEComponent2D) -> (Any.Type, Data)? {
    guard let value = SafeKVC.value(forKey: name, of: component) else { return nil }
   
    let type = type(of: value)
    guard let encodableValue = value as? Encodable else {
        TELogger2D.print("error. TEEncodedComponent2D. try to encode non Encodable value. Just silent skip it")
        return nil
    }
    let encoder = JSONEncoder()
    let valueData = try! encoder.encode(encodableValue )
    return (type, valueData)
}
