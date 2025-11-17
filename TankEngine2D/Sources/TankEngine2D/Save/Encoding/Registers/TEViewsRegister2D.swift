//
//  TEViewsRegister.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 06.11.2025.
//

@MainActor
public class TEViewsRegister2D {
    public static let shared = TEViewsRegister2D()
    
    private var coreViews: [String: any TEView2D.Type] = [:]
    public private(set) var views: [String: any TEView2D.Type] = [:]
    private var autoRegistrator: TEAutoRegistratorProtocol!
    
    private init() {}
    
    func setAutoRegistrator(_ autoRegistrator: TEAutoRegistratorProtocol) {
        self.autoRegistrator = autoRegistrator
    }
    
    public func getTypeBy(_ key: String) -> (any TEView2D.Type)? {
        if let view = coreViews[key] { return  view}
        if let view = views[key] { return  view}
        if let view = autoRegistrator.views[key] { return view}
        return nil
    }
    
    public func getKeyFor(_ type: any TEView2D.Type) -> String {
        return String(reflecting: type)
    }
    
    public func register(_ _type: any TEView2D.Type) {
        views[getKeyFor(_type)] = _type
    }
}

extension TEViewsRegister2D {
    func registerCoreViews() {
        registerCore(TEMissedView2D.self)
    }
    
    func registerCore(_ _type: any TEView2D.Type) {
        views[String(reflecting: _type)] = _type
    }
}
