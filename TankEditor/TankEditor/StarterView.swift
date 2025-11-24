//
//  ContentView.swift
//  Editor
//
//  Created by Sergey Kozlov on 17.11.2025.
//

import SwiftUI
import TankEngine2D

private struct ProjectPathKey: EnvironmentKey {
    static let defaultValue: String = ""
}

extension EnvironmentValues {
    var projectPath: String {
        get { self[ProjectPathKey.self] }
        set { self[ProjectPathKey.self] = newValue }
    }
}

struct StarterView: View {
    let defaultPath = "/Users/sergeykozlov/Documents/TankEngineProjects/Sandbox"
    @State var isOpened = false
    var body: some View {
        if (isOpened) {
            EditorView()
                .environment(\.projectPath, defaultPath)
        }
        else {
            Button("open") {
                isOpened = true
            }
        }
    }
}

#Preview {
    StarterView()
}
