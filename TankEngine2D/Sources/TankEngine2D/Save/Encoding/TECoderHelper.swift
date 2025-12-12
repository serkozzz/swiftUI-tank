//
//  TECoderHelper.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 11.11.2025.
//
import Foundation

@MainActor
class TECoderHelper {
    static func encodeRef(propertyName: String, componentRef: TEComponent2D) -> TEComponentRefDTO? {

        let valueData = try! JSONEncoder().encode(componentRef.id)
    
        let valueJsonStr = String(data: valueData, encoding: .utf8)!
        return TEComponentRefDTO(propertyName: propertyName,
                             propertyValue: valueJsonStr)
    }
    
    static func tryEncodeRef(mirrorProp: Mirror.Child) -> TEComponentRefDTO? {
        guard let componentRef = mirrorProp.value as? TEComponent2D else { return nil }
        guard let propertyName = mirrorProp.label else { return nil }
        return TECoderHelper.encodeRef(propertyName: propertyName, componentRef: componentRef)
    }

}

