//
//  Untitled.swift
//  UserCodeDylib
//
//  Created by Sergey Kozlov on 17.11.2025.
//
import TankEngine2D

@MainActor
@_cdecl("registerComponents")
public func registerComponents() {
    print("[UserCodeDylib] registerComponents() called")

    TETankEngine2D.shared.start(TEAutoRegistrator2D())
    TETankEngine2D.shared.pause()
    // Регистрация пользовательских типов
    TEComponentsRegister2D.shared.register(PlayerLogic.self)
    TEComponentsRegister2D.shared.register(UserRectangle.self)
    TEViewsRegister2D.shared.register(RectView.self)
    TEViewsRegister2D.shared.register(CircleView.self)
    
}
