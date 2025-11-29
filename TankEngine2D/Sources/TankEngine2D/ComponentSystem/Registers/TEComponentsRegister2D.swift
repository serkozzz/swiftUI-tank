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
    private var autoRegistrator: TEAutoRegistratorProtocol?
    private var coreComponents: [String: TEComponent2D.Type] = [:]
    public private(set)var components: [String: TEComponent2D.Type] = [:]
    
    private init() {}
    
    func setAutoRegistrator(_ autoRegistrator: TEAutoRegistratorProtocol) {
        self.autoRegistrator = autoRegistrator
    }
    
    public func getTypeBy(_ key: String) -> TEComponent2D.Type? {
        if let component = coreComponents[key] { return  component}
        if let component = components[key] { return  component}
        if let autoRegistrator {
            if let component = autoRegistrator.components[key] { return  component }
        }
        return nil
    }
    
    public func getKeyFor(_ type: TEComponent2D.Type) -> String {
        return String(describing: type)
    }
    
    public func register(_ _type: TEComponent2D.Type) {
        components[getKeyFor(_type)] = _type
    }
}


extension TEComponentsRegister2D {
    
    func registerCoreComponents() {
        registerCore(TECamera2D.self)
        registerCore(TECollider2D.self)
        registerCore(TEMissedComponent2D.self)
        registerCore(TERectangle2D.self)
    }
    
    func registerCore(_ _type: TEComponent2D.Type) {
        coreComponents[getKeyFor(_type)] = _type
    }
}
