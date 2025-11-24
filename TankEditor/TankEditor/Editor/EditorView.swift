//
//  ContentView.swift
//  Editor
//
//  Created by Sergey Kozlov on 17.11.2025.
//

import SwiftUI
import TankEngine2D

struct EditorView: View {

    var body: some View {
        VStack() {
            HStack {
                SceneTreeView()
                //Scene2DView()
                PropsInstectorView()
            }
            AssetsBrowserView()
        }

    }
}

#Preview {
    EditorView()
        .environment(\.projectPath, "/Users/sergeykozlov/Documents/TankEngineProjects/Sandbox")
}
