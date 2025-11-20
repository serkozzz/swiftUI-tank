//
//  PluginLoader.swift
//  TankEditor
//
//  Created by Sergey Kozlov on 18.11.2025.
//

import Darwin
import Foundation

@MainActor
final class PluginLoader {

    static let shared = PluginLoader()

    private init() {}

    private var pluginPath: String {
        let pluginsURL = Bundle.main.bundleURL
            .appendingPathComponent("Contents/PlugIns")

        let dylibURL = pluginsURL.appendingPathComponent("libUserCodeDylib.dylib")
        return dylibURL.path
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
