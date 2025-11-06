//
//  ComponentsRegister.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 29.10.2025.
//

import SwiftUI

@MainActor
public class TEComponentsRegister2D {
    public static let shared = TEComponentsRegister2D()
    
    var registredComponents: [String: TEComponent2D.Type] = [:]
    func registerCoreComponents() {
        register(TECamera2D.self)
        register(TECollider2D.self)
        register(TEMissedComponent2D.self)
    }
    
    public func register(_ _type: TEComponent2D.Type) {
        registredComponents[String(reflecting: _type)] = _type
    }
}
