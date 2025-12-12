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
        unwrapPublishedType(owner, propName: propName)
    }
}



