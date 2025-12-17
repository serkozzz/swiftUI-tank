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
    TETankEngine2D.shared.setAutoRegistrator(TEAutoRegistrator2D())
}
