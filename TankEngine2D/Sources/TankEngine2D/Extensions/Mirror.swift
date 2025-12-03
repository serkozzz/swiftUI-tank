//
//  Mirror.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 05.11.2025.
//

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
    
    static func getPropType(_ subject: Any, propName: String) -> Any.Type? {
        var result: Any.Type?
        Mirror.propsForeach(subject) { prop in
            if (prop.label == propName) {
                result = type(of: prop.value)
            }
        }
        return result
    }
}
