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
        
        //encode id
        let idData = try! JSONEncoder().encode(component.id)
        result.append( TEEncodedComponent2DProperty(propertyName: "id",
                                                    propertyValue: idData,
                                                    propertyType: "UUID" ))
    
        //encode all previewable
        var current: Mirror? = Mirror(reflecting: component)
        while let mirror = current {
            for child in mirror.children {
                
                guard let previewable = child.value as? TEPreviewable2DProtocol else { continue }
                guard let propertyName = child.label else { continue }
                
                
                let valueData = try! JSONEncoder().encode(previewable.value)
                result.append( TEEncodedComponent2DProperty(propertyName: propertyName,
                                                            propertyValue: valueData,
                                                            propertyType: String(reflecting: previewable.valueType) ))
            }
            current = mirror.superclassMirror
        }
        
        return result
    }
    
    private func restorePreviewableProperties(for component: TEComponent2D) {
        //decode id
        guard let idProp = self.properties.first(where: { $0.propertyName == "id"}) else {
            TELogger2D.print("Could not find id in encoded data of component: \(String(describing: type(of: component)))")
            return
        }
        guard let decodedIdValue = try? JSONDecoder().decode(UUID.self, from: idProp.propertyValue) else {
            TELogger2D.print("Could not decode id of component(UUID decode error): \(String(describing: type(of: component)))")
            return
        }
        component.id = decodedIdValue
        
        //decode all previewable
        var current: Mirror? = Mirror(reflecting: component)
        while let mirror = current {
            for child in mirror.children {
                guard let previewable = child.value as? TEPreviewable2DProtocol else { continue }
                guard let property = self.properties.first(where: { $0.propertyName == child.label}) else { continue }
                
                let innerType = previewable.self.valueType
                guard let decodedValue = try? JSONDecoder().decode(innerType, from: property.propertyValue)
                else {
                    TELogger2D.print("Could not restore innerValue for Previewable<> property: \(property.propertyName) of type: \(String(describing: previewable.valueType))")
                    continue
                }
                
                // Устанавливаем значение внутрь обёртки
                if !previewable.setValue(decodedValue) {
                    TELogger2D.print("Type mismatch when assigning decoded value to Previewable<> property: \(property.propertyName)")
                }
            }
            current = mirror.superclassMirror
        }
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
