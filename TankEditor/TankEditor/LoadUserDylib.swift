//
//  LoadUserDlyb.swift
//  Editor
//
//  Created by Sergey Kozlov on 17.11.2025.
//
import Darwin

func loadUserDylib() {
    let dylibPath = "/Users/sergeykozlov/Documents/repositories/swiftUI-tank/UserCodeDylib/.build/arm64-apple-macosx/debug/libUserCodeDylib.dylib"

    // Загружаем библиотеку
    let handle = dlopen(dylibPath, RTLD_NOW | RTLD_LOCAL)
    if handle == nil {
        print("❌ dlopen failed:", String(cString: dlerror()))
        return
    }
    print("✅ Dylib loaded")

    // Ищем экспортированную C-функцию
    guard let sym = dlsym(handle, "registerComponents") else {
        print("❌ dlsym failed: registerComponents not found")
        return
    }

    typealias RegisterFn = @convention(c) () -> Void
    let fn = unsafeBitCast(sym, to: RegisterFn.self)

    print("👉 Calling registerComponents()")
    fn()
}
