//
//  ContentView.swift
//  app
//
//  Created by Sergey Kozlov on 27.11.2025.
//

import SwiftUI
import TankEngine2D

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }.onAppear() {
            TETankEngine2D.shared.start()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
