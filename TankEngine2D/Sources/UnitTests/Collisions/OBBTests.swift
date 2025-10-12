//
//  OBBTests.swift
//  UnitTests
//
//  Created by Sergey Kozlov on 12.10.2025.
//

import XCTest
import simd
@testable import TankEngine2D

@MainActor
final class OBBTests: XCTestCase {
    
    // Helpers
    
    private func obb(center: SIMD2<Float>, size: CGSize, rotationCW degrees: Double = 0) -> TEOBB {
        let t = TETransform2D(position: center)
        if degrees != 0 {
            t.setRotation(clockwiseAngle: .degrees(degrees))
        }
        return TEOBB(worldTransform: t, size: size)
    }
    
    private func aabb(center: SIMD2<Float>, size: CGSize) -> TEAABB {
        TEAABB(center: center, size: size)
    }
    
    // MARK: - Intersections
    
    func testNoIntersectionFarApart_noRotation() {
        let A = obb(center: SIMD2<Float>(0, 0), size: CGSize(width: 10, height: 10))
        let B = obb(center: SIMD2<Float>(100, 100), size: CGSize(width: 10, height: 10))
        XCTAssertFalse(A.intersects(B))
        XCTAssertFalse(B.intersects(A))
    }
    
    func testIntersectionOverlap_noRotation() {
        let A = obb(center: SIMD2<Float>(0, 0), size: CGSize(width: 10, height: 10))
        let B = obb(center: SIMD2<Float>(5, 0), size: CGSize(width: 10, height: 10)) // перекрытие по X
        XCTAssertTrue(A.intersects(B))
        XCTAssertTrue(B.intersects(A))
    }
    
    func testTouchingEdgesCountsAsIntersection_noRotation() {
        // Половины по X = 5 у каждого, центры на (0,0) и (10,0) => касание по X
        let A = obb(center: SIMD2<Float>(0, 0), size: CGSize(width: 10, height: 10))
        let B = obb(center: SIMD2<Float>(10, 0), size: CGSize(width: 10, height: 10))
        XCTAssertTrue(A.intersects(B))
        XCTAssertTrue(B.intersects(A))
    }
    
    func testSeparatedOnXOnly_noRotation() {
        // Половины по X = 5, центры на (0,0) и (20,0) => разнесены по X
        let A = obb(center: SIMD2<Float>(0, 0), size: CGSize(width: 10, height: 10))
        let B = obb(center: SIMD2<Float>(20, 0), size: CGSize(width: 10, height: 10))
        XCTAssertFalse(A.intersects(B))
        XCTAssertFalse(B.intersects(A))
    }
    
    func testSeparatedOnYOnly_noRotation() {
        let A = obb(center: SIMD2<Float>(0, 0), size: CGSize(width: 10, height: 10))
        let B = obb(center: SIMD2<Float>(0, 20), size: CGSize(width: 10, height: 10))
        XCTAssertFalse(A.intersects(B))
        XCTAssertFalse(B.intersects(A))
    }
    
    func testIntersectionWithRotation_90deg() {
        // A: вертикальная палка (без поворота), B: горизонтальная палка, повернута на 90° (в итоге вертикальная)
        let A = obb(center: SIMD2<Float>(0, 0), size: CGSize(width: 10, height: 40))
        let B = obb(center: SIMD2<Float>(0, 0), size: CGSize(width: 40, height: 10), rotationCW: 90)
        XCTAssertTrue(A.intersects(B))
        XCTAssertTrue(B.intersects(A))
    }
    
    func testIntersectionWithRotation_arbitraryAngle() {
        // Два одинаковых прямоугольника, один повернут на 30°, центры близко — должно пересекаться.
        let A = obb(center: SIMD2<Float>(0, 0), size: CGSize(width: 20, height: 10))
        let B = obb(center: SIMD2<Float>(8, 2), size: CGSize(width: 20, height: 10), rotationCW: 30)
        XCTAssertTrue(A.intersects(B))
        XCTAssertTrue(B.intersects(A))
    }
    
    func testNoIntersectionWithRotation_arbitraryAngle() {
        // Разнесём достаточно по X при повороте — не пересекаются
        let A = obb(center: SIMD2<Float>(0, 0), size: CGSize(width: 20, height: 10))
        let B = obb(center: SIMD2<Float>(100, 0), size: CGSize(width: 20, height: 10), rotationCW: 30)
        XCTAssertFalse(A.intersects(B))
        XCTAssertFalse(B.intersects(A))
    }
    
    func testTouchingCornerCountsAsIntersection_withRotation() {
        // Настроим так, чтобы один угол касался: A без поворота, B повернут и сдвинут.
        let A = obb(center: SIMD2<Float>(0, 0), size: CGSize(width: 10, height: 10))
        // half=5; возьмём B так, чтобы один угол касался (примерно)
        let B = obb(center: SIMD2<Float>(10, 10), size: CGSize(width: 10, height: 10), rotationCW: 45)
        XCTAssertTrue(A.intersects(B), "Касание углом считаем пересечением")
        XCTAssertTrue(B.intersects(A))
    }
    
    // MARK: - Fully inside AABB (scene bounds)
    
    func testFullyInsideAABB_centered_noRotation() {
        let bounds = aabb(center: SIMD2<Float>(0, 0), size: CGSize(width: 100, height: 100))
        let obbInside = obb(center: SIMD2<Float>(0, 0), size: CGSize(width: 20, height: 20))
        XCTAssertTrue(obbInside.isFullyInsideAABB(bounds))
    }
    
    func testFullyInsideAABB_touchingEdge_noRotation() {
        let bounds = aabb(center: SIMD2<Float>(0, 0), size: CGSize(width: 10, height: 10)) // half=5
        // Сделаем OBB, касающийся границы по X: центр.x = -5 + halfX = -5 + 2 = -3
        let obbTouch = obb(center: SIMD2<Float>(-3, 0), size: CGSize(width: 4, height: 6))
        XCTAssertTrue(obbTouch.isFullyInsideAABB(bounds), "Касание границы допускается")
    }
    
    func testFullyInsideAABB_withRotation() {
        let bounds = aabb(center: SIMD2<Float>(0, 0), size: CGSize(width: 100, height: 100))
        // Повернутый прямоугольник в центре — точно внутри
        let obbRot = obb(center: SIMD2<Float>(0, 0), size: CGSize(width: 20, height: 10), rotationCW: 30)
        XCTAssertTrue(obbRot.isFullyInsideAABB(bounds))
    }
    
    func testNotFullyInsideAABB_exceedsOnX() {
        let bounds = aabb(center: SIMD2<Float>(0, 0), size: CGSize(width: 10, height: 10)) // minX=-5, maxX=5
        // Сдвинем и повернём так, чтобы крайняя вершина ушла правее 5
        let obb = obb(center: SIMD2<Float>(4, 0), size: CGSize(width: 6, height: 6), rotationCW: 30)
        XCTAssertFalse(obb.isFullyInsideAABB(bounds))
    }
    
    func testNotFullyInsideAABB_exceedsOnY() {
        let bounds = aabb(center: SIMD2<Float>(0, 0), size: CGSize(width: 10, height: 10)) // minY=-5, maxY=5
        let obb = obb(center: SIMD2<Float>(0, 4), size: CGSize(width: 6, height: 6), rotationCW: 45)
        XCTAssertFalse(obb.isFullyInsideAABB(bounds))
    }
    
    // MARK: - Edge cases
    
    func testZeroSizeOBB_inside() {
        let bounds = aabb(center: SIMD2<Float>(0, 0), size: CGSize(width: 10, height: 10))
        // Точка
        let pointOBB = obb(center: SIMD2<Float>(0, 0), size: CGSize(width: 0, height: 0))
        XCTAssertTrue(pointOBB.isFullyInsideAABB(bounds))
        
        // На границе
        let pointOnEdge = obb(center: SIMD2<Float>(5, 0), size: CGSize(width: 0, height: 0))
        XCTAssertTrue(pointOnEdge.isFullyInsideAABB(bounds))
        
        // Вне
        let pointOutside = obb(center: SIMD2<Float>(6, 0), size: CGSize(width: 0, height: 0))
        XCTAssertFalse(pointOutside.isFullyInsideAABB(bounds))
    }
    
    func testThinLineOBB_inside() {
        let bounds = aabb(center: SIMD2<Float>(0, 0), size: CGSize(width: 10, height: 10))
        // Тонкая линия по X (height ~ 0), полностью внутри
        let lineX = obb(center: SIMD2<Float>(0, 0), size: CGSize(width: 8, height: 0))
        XCTAssertTrue(lineX.isFullyInsideAABB(bounds))
        
        // Линия по Y, касающаяся верхней границы
        let lineYTouch = obb(center: SIMD2<Float>(0, 2), size: CGSize(width: 0, height: 6))
        XCTAssertTrue(lineYTouch.isFullyInsideAABB(bounds))
        
        // Линия выходит за предел
        let lineOutside = obb(center: SIMD2<Float>(0, 3), size: CGSize(width: 0, height: 8))
        XCTAssertFalse(lineOutside.isFullyInsideAABB(bounds))
    }
}
