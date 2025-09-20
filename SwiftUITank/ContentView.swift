//
//  ContentView.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 26.08.2025.
//

import SwiftUI
import simd

struct ContentView: View {

    @StateObject var gameModel = GameModel()
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            Color.clear
                .playerController(player: gameModel.player)

        }
        
        .padding()


    }
}

#Preview {
    ContentView()
}
