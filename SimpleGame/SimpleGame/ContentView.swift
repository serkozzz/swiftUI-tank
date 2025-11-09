//
//  ContentView.swift
//  SimpleGame
//
//  Created by Sergey Kozlov on 07.11.2025.
//

import SwiftUI
import TankEngine2D

struct ContentView: View {
    
    @ObservedObject var vm = GameViewModel()
    
    var body: some View {
        ZStack(alignment: .top) {
            
            TESceneRender2D(scene: vm.scene)
            HStack {
                Spacer()
                HStack {
                    Spacer()
                    Button("Save") {
                        vm.saveScene()
                    }
                    .background(.yellow)
                    Button("Load") {
                        vm.loadScene()
                    }
                    .background(.yellow)
                }
            }
        }
        
        .onTapGesture {
            vm.tap()
        }
        
    }
}

#Preview {
    //  ContentView()
}
