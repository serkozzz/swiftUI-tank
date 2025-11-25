//
//  TEAutoRegistrator.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 16.11.2025.
//

@MainActor
public protocol TEAutoRegistratorProtocol: AnyObject {
    var components: [String: TEComponent2D.Type] { get }
    var views: [String: any TEView2D.Type] { get }
}
