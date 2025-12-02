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

    // Регистрация пользовательских типов
    TEComponentsRegister2D.shared.register(PlayerLogic.self)
    TEViewsRegister2D.shared.register(RectView.self)
    TEViewsRegister2D.shared.register(CircleView.self)
}
