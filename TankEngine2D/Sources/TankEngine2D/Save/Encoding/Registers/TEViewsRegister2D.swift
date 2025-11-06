//
//  TEViewsRegister.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 06.11.2025.
//

@MainActor
public class TEViewsRegister2D {
    public static let shared = TEViewsRegister2D()
    
    var registredViews: [String: any TEView2D.Type] = [:]
    
    func registerCoreViews() {
        register(TEMissedView2D.self)
    }
    
    public func register(_ _type: any TEView2D.Type) {
        registredViews[String(reflecting: _type)] = _type
    }
    
}
