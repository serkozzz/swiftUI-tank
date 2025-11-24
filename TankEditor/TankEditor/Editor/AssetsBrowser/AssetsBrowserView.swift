//
//  ContentView.swift
//  Editor
//
//  Created by Sergey Kozlov on 17.11.2025.
//

import SwiftUI
import TankEngine2D

struct AssetsBrowserView: View {
    @Environment(\.projectPath) private var projectPath: String
    var body: some View {
        Color.cyan
    }
}

#Preview {
    AssetsBrowserView().environment(\.projectPath, "/Users/sergeykozlov/Documents/TankEngineProjects/Sandbox")
}
