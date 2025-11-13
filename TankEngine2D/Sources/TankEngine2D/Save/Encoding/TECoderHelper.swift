//
//  TECoderHelper.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 11.11.2025.
//
import Foundation

@MainActor
class TECoderHelper {
    
    
    static func tryEncodePreviewable(mirrorProp: Mirror.Child) -> TEPropertyDTO? {
        guard let previewable = mirrorProp.value as? (any TEPreviewable2D) else { return nil }
        guard let propertyName = mirrorProp.label else { return nil }
        
        let valueData = try! JSONEncoder().encode(previewable)
        let valueJsonStr = String(data: valueData, encoding: .utf8)!
    
        return TEPropertyDTO(propertyName: propertyName,
                                     propertyValue: valueJsonStr,
                                     propertyType: String(reflecting: previewable.valueType) )
    }
    
    static func tryEncodeRef(mirrorProp: Mirror.Child) -> TEPropertyDTO? {
        guard let componentRef = mirrorProp.value as? TEComponent2D else { return nil }
        guard let propertyName = mirrorProp.label else { return nil }
        
        
        let valueData = try! JSONEncoder().encode(componentRef.id)
    
        let valueJsonStr = String(data: valueData, encoding: .utf8)!
        return TEPropertyDTO(propertyName: propertyName,
                             propertyValue: valueJsonStr,
                             propertyType: String(reflecting: UUID.self) )
    }
    
    static func tryRestorePreviewable(mirrorProp: Mirror.Child,
                                      allPropertieDTOs: [TEPropertyDTO]) -> (any TEPreviewable2D)? {
        
        if var previewable = mirrorProp.value as? (any TEPreviewable2D) {
            return restoreIntoPreviewable(&previewable, mirrorProp: mirrorProp, allPropertieDTOs: allPropertieDTOs)
        }
        
//        if (mirrorProp.label == "size") {
//            var a = 10
//        }
//
//        if let previewableOpt = mirrorProp.value as? (any TEPreviewable2D)? {
//       
//            let _type = type(of: mirrorProp.value)
//            print(_type)
//            
//        }
//        // Пытаемся распаковать Optional и привести уже вложенное значение
//        let mirror = Mirror(reflecting: mirrorProp.value)
//        if mirror.displayStyle == .optional, let someChild = mirror.children.first?.value {
//            if var previewable = someChild as? (any TEPreviewable2D) {
//                return restoreIntoPreviewable(&previewable, mirrorProp: mirrorProp, allPropertieDTOs: allPropertieDTOs)
//            }
//        }

        return nil
    }
    
    // Вспомогательная функция, чтобы не дублировать логику
    private static func restoreIntoPreviewable(_ previewable: inout any TEPreviewable2D,
                                               mirrorProp: Mirror.Child,
                                               allPropertieDTOs: [TEPropertyDTO]) -> (any TEPreviewable2D)? {
        guard let property = allPropertieDTOs.first(where: { $0.propertyName == mirrorProp.label }) else { return nil }
        
        let innerType = previewable.valueType
        guard let data = property.propertyValue.data(using: .utf8) else {
            TELogger2D.error("restorePreviewableProperties. Could not convert JSON string to Data for : \(property.propertyName)")
            return nil
        }
        
        guard let decodedValue = try? JSONDecoder().decode(innerType, from: data) else {
            TELogger2D.error("Could not restore innerValue for Previewable<> property: \(property.propertyName) of type: \(String(describing: innerType))")
            return nil
        }
        
        if !previewable.setValueAny(decodedValue) {
            TELogger2D.print("Type mismatch when assigning decoded value to Previewable<> property: \(property.propertyName)")
            return nil
        }
        return previewable
    }
}

