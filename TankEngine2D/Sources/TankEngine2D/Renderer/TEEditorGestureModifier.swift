//
//  TESceneRendererModifier.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 23.12.2025.
//

import SwiftUI

struct TEEditorGestureModifier: ViewModifier {

    let enabled: Bool
    let node: TESceneNode2D
    let camera: TECamera2D

    @State var nodePosWhenDragStarted: SIMD2<Float>?
    @State private var position: CGPoint = .zero
    
    func body(content: Content) -> some View {
        if enabled {
            content
                .gesture(
                     DragGesture()
                         .onChanged { value in
                             if nodePosWhenDragStarted == nil {
                                 nodePosWhenDragStarted = node.transform.position
                             }
                             let translation = SIMD2<Float>( x: Float(value.translation.width),
                                                             y: Float(value.translation.height))
                             print ("drag. \(node.displayName) translation: \(translation)")
                             node.transform.setPosition(nodePosWhenDragStarted! + translation)
                         }
                         .onEnded { value in
                             nodePosWhenDragStarted = nil
                         }
                 )
        } else {
            content
        }
    }
}


extension View {
    func teEditorGestureModifier(enabled: Bool, node: TESceneNode2D, camera: TECamera2D) -> some View {
        self.modifier(TEEditorGestureModifier(enabled: enabled, node: node, camera: camera))
    }
}
