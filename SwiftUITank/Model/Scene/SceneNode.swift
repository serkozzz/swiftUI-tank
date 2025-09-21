
//
//  Untitled.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 21.09.2025.
//
import Foundation

class SceneNode: Identifiable {
    private var transform: Matrix
    var geometryObject: GeometryObject?
    
    var position: SIMD2<Float> {
        SIMD2<Float> (self.transform.columns.2.x, self.transform.columns.2.y)
    }
//    var cgPosition: CGPoint {
//        CGPoint(x: Double(self.transform.columns.2.x), y: Double(self.transform.columns.2.y))
//    }
    
    init(transform: Matrix, geometryObject: GeometryObject? = nil) {
        self.transform = transform
        self.geometryObject = geometryObject
    }
    
    init(position: SIMD2<Float>, geometryObject: GeometryObject? = nil) {
        self.transform = Matrix.init(diagonal: .one)
        self.transform.columns.2.x = position.x
        self.transform.columns.2.y = position.y
        self.geometryObject = geometryObject
    }
}
