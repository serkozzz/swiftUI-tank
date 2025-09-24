//
//  Camera.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 20.09.2025.
//
import simd
import SwiftUI



class Camera: Component  {

    func move(_ vector: SIMD2<Float>) {
        transform?.move(vector)
    }
    
    func screenToWorld(_ point: SIMD2<Float>, viewportSize: CGSize) -> SIMD2<Float> {
        guard let transform else { printNotAttachedError(); fatalError();}
        
        var worldPoint = SIMD3<Float>(point, 1)
        worldPoint.y = Float(viewportSize.height) - worldPoint.y
        
        let result = transform.matrix * worldPoint
        return SIMD2<Float>(result.x, result.y)
    }
    
    func worldToScreen(worldPosition: SIMD2<Float>) -> CGPoint {
        guard let transform else { printNotAttachedError(); fatalError(); }
        
        let position = SIMD3<Float>(worldPosition, 1)
        let viewMatrix = transform.matrix.inverse
        let result = viewMatrix * position
        return CGPoint(x: Double(result.x), y: Double(result.y))
        
        
    }
    
    private func printNotAttachedError() {
        print("ERROR! Camera should be attached to the scene node.")
    }
}
