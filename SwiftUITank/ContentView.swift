//
//  ContentView.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 26.08.2025.
//

import SwiftUI
import simd

struct ContentView: View {
    @State var position: CGPoint = CGPoint(x: 100, y: 300)
    @State var tankCenter: CGPoint!
    @State var isTouched = false
    @State var barrelDirection = SIMD2<Float>(0, -1)
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            TankView(barrelDirection: barrelDirection)
                .readCenter()
                .position(position)
                .onPreferenceChange(CenterPreferenceKey.self) { value in
                    self.tankCenter = value
                }
        }
        
        .padding()
        .background {
            KeyPressHandler { key in
                switch key {
                case .up: position.y -= 10
                case .down: position.y += 10
                case .left: position.x -= 10
                case .right: position.x += 10
                }
                
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .global)
                .onChanged() { value in
                    if (!isTouched) {
                        isTouched = true
                    }
                    let location = value.location
                    barrelDirection = SIMD2(Float(location.x - tankCenter.x),
                                            Float(location.y - tankCenter.y))
                }
                .onEnded() {_ in
                    isTouched = false
                }
        )
    }
}

#Preview {
    ContentView()
}
