//
//  Camera.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 20.09.2025.
//
import simd
import SwiftUI


/// Coordinate system details:
/// - The renderer is flipped along the Y axis (origin at bottom-left), while gesture inputs
///   typically come from a non-flipped UIKit/SwiftUI coordinate space (origin at top-left).
///   `screenToWorld(_:)` compensates by inverting Y using the current `viewportSize`.
public class TECamera2D: TEComponent2D  {
    
    @Published public var viewportSize: CGSize = .zero

    public func move(_ vector: SIMD2<Float>) {
        transform?.move(vector)
    }
    
    ///
    public func screenToWorld(_ point: SIMD2<Float>) -> SIMD2<Float> {
        guard let transform else { printNotAttachedError(); fatalError();}
        //we invert Y in screenToWorld because user will hang .gesture on unflipped View outside the sceneRenderer.
        //The same time SceneREnderer2D flipped by Oy.
        //We don't need to do it in worldToScreen because worldToScreen usualy works inside engine ecosystem
        //where we work with already flipped coords only.
        let invertedY = SIMD2<Float>(point.x, Float(viewportSize.height) - point.y)
        
        let cameraSpace = invertedY - SIMD2<Float>(cgSize: viewportSize) / 2
        let cameraSpaceHomogeneous = SIMD3<Float>(cameraSpace, 1)
        
        //cameraSpaceHomogeneous.y = Float(viewportSize.height) - cameraSpaceHomogeneous.y
        let result = transform.matrix * cameraSpaceHomogeneous
        return SIMD2<Float>(result.x, result.y)
    }
    
    public func worldToScreen(worldPosition: SIMD2<Float>) -> CGPoint {
        guard let transform else { printNotAttachedError(); fatalError(); }
        
        let worldHomogeneous = SIMD3<Float>(worldPosition, 1)
        let viewMatrix = transform.matrix.inverse
        let cameraSpace = viewMatrix * worldHomogeneous
        
        // чтобы центр системы коорд. камеры оказался по центру экрана делаем доп. смещение
        let result = SIMD2<Float>(cameraSpace) + SIMD2(cgSize: viewportSize) / 2
        
        return CGPoint(x: Double(result.x), y: Double(result.y))
    }
    
    private func printNotAttachedError() {
        print("ERROR! Camera should be attached to the scene node.")
    }
}

