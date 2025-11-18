//
//  PluginLoader.swift
//  TankEditor
//
//  Created by Sergey Kozlov on 18.11.2025.
//

import Darwin
import Foundation

final class PluginLoader {

    static let shared = PluginLoader()

    private init() {}

    private var pluginPath: String {
        let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("TankEditor/Plugins/libUserCodeDylib.dylib")
        return url.path
    }

    func load() {
        let path = pluginPath
        print("Trying to load:", path)

        let handle = dlopen(path, RTLD_NOW | RTLD_LOCAL)

        guard let handle else {
            if let err = dlerror() {
                print("❌ dlopen error:", String(cString: err))
            } else {
                print("❌ dlopen failed for unknown reason")
            }
            return
        }
        print("✅ Plugin loaded:", path)
        

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
}
