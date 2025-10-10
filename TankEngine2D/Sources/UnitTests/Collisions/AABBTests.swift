//
//  AABBIntersectionTests.swift
//  UnitTests
//
//  Created by Sergey Kozlov on 05.10.2025.
//

import XCTest
import simd
@testable import TankEngine2D

//MARK: Intersectoin
@MainActor
final class AABBTests: XCTestCase {
    
    private func aabb(_ center: SIMD2<Float>, _ size: CGSize) -> TEAABB {
        TEAABB(center: center, size: size)
    }
    
    func testNoIntersectionFarApart() {
        let a = aabb(SIMD2<Float>(0, 0), CGSize(width: 10, height: 10))
        let b = aabb(SIMD2<Float>(100, 100), CGSize(width: 10, height: 10))
        
        XCTAssertFalse(a.intersects(b))
        XCTAssertFalse(b.intersects(a), "Пересечение должно быть симметричным")
    }
    
    func testIntersectionOverlap() {
        let a = aabb(SIMD2<Float>(0, 0), CGSize(width: 10, height: 10))
        let b = aabb(SIMD2<Float>(5, 0), CGSize(width: 10, height: 10)) // перекрытие по X, совпадение по Y
        
        XCTAssertTrue(a.intersects(b))
        XCTAssertTrue(b.intersects(a))
    }
    
    func testTouchingEdgesCountsAsIntersection() {
        // Касание по X: maxA.x == minB.x
        let a = aabb(SIMD2<Float>(0, 0), CGSize(width: 10, height: 10))  // half = 5
        let b = aabb(SIMD2<Float>(10, 0), CGSize(width: 10, height: 10)) // minB.x = 5, maxA.x = 5
        
        XCTAssertTrue(a.intersects(b), "Касание граней считаем пересечением")
        XCTAssertTrue(b.intersects(a))
    }
    
    func testSeparatedOnXOnly() {
        let a = aabb(SIMD2<Float>(0, 0), CGSize(width: 10, height: 10))
        let b = aabb(SIMD2<Float>(20, 0), CGSize(width: 10, height: 10)) // дистанция по X > сумма полуразмеров (10)
        
        XCTAssertFalse(a.intersects(b))
        XCTAssertFalse(b.intersects(a))
    }
    
    func testSeparatedOnYOnly() {
        let a = aabb(SIMD2<Float>(0, 0), CGSize(width: 10, height: 10))
        let b = aabb(SIMD2<Float>(0, 20), CGSize(width: 10, height: 10)) // дистанция по Y > сумма полуразмеров (10)
        
        XCTAssertFalse(a.intersects(b))
        XCTAssertFalse(b.intersects(a))
    }
    
    func testContainment() {
        let big = aabb(SIMD2<Float>(0, 0), CGSize(width: 100, height: 100))
        let small = aabb(SIMD2<Float>(10, 10), CGSize(width: 10, height: 10))
        
        XCTAssertTrue(big.intersects(small))
        XCTAssertTrue(small.intersects(big))
    }
    
}

//MARK: FullyInside
@MainActor
extension AABBTests {
    
    // MARK: - isFullyInside tests
    
    func testFullyInsideWithMargins() {
        let outer = aabb(SIMD2<Float>(0, 0), CGSize(width: 100, height: 100)) // half = 50
        let inner = aabb(SIMD2<Float>(0, 0), CGSize(width: 20, height: 20))   // half = 10
        // inner min/max: [-10, -10] .. [10, 10]
        // outer min/max: [-50, -50] .. [50, 50]
        XCTAssertTrue(inner.isFullyInside(outer))
        XCTAssertFalse(outer.isFullyInside(inner))
    }
    
    func testIdenticalAABBsAreFullyInside() {
        let a = aabb(SIMD2<Float>(5, -3), CGSize(width: 42, height: 24))
        let b = a
        XCTAssertTrue(a.isFullyInside(b), "Одинаковые AABB считаются полностью внутри (касание допускается)")
        XCTAssertTrue(b.isFullyInside(a))
    }
    
    func testTouchingOnOneSideIsFullyInside() {
        // inner касается левой границы outer
        let outer = aabb(SIMD2<Float>(0, 0), CGSize(width: 10, height: 10)) // half = 5, minX = -5
        // Сделаем inner так, чтобы его minX == -5
        // Пусть inner.width = 4 (half = 2), тогда center.x должен быть -3, чтобы minX = -5
        let inner = aabb(SIMD2<Float>(-3, 0), CGSize(width: 4, height: 6))
        XCTAssertTrue(inner.isFullyInside(outer), "Касание границы допускается для полного включения")
    }
    
    func testTouchingAtCornerIsFullyInside() {
        let outer = aabb(SIMD2<Float>(0, 0), CGSize(width: 10, height: 10)) // min = (-5,-5), max = (5,5)
        // inner: min = (-5,-5), max = (-1,-1) => центр (-3,-3), size (8,8)? Нет, half=4 даст min=-7.
        // Возьмем size = 8 -> half = 4, чтобы corner касался minX и minY outer: center = (-1, -1) даст min = (-5,-5)
        let inner = aabb(SIMD2<Float>(-1, -1), CGSize(width: 8, height: 8))
        XCTAssertTrue(inner.isFullyInside(outer))
    }
    
    func testOverlapButNotFullyInsideOnX() {
        let outer = aabb(SIMD2<Float>(0, 0), CGSize(width: 10, height: 10)) // minX = -5, maxX = 5
        let inner = aabb(SIMD2<Float>(4, 0), CGSize(width: 6, height: 6))   // halfX = 3 -> maxX = 7 > 5
        XCTAssertFalse(inner.isFullyInside(outer))
    }
    
    func testOverlapButNotFullyInsideOnY() {
        let outer = aabb(SIMD2<Float>(0, 0), CGSize(width: 10, height: 10)) // minY = -5, maxY = 5
        let inner = aabb(SIMD2<Float>(0, 4), CGSize(width: 6, height: 6))   // halfY = 3 -> maxY = 7 > 5
        XCTAssertFalse(inner.isFullyInside(outer))
    }
    
    func testOutsideOnBothAxes() {
        let outer = aabb(SIMD2<Float>(0, 0), CGSize(width: 10, height: 10))
        let inner = aabb(SIMD2<Float>(6, 6), CGSize(width: 4, height: 4)) // minX = 4 > 5? half=2, min=4, max=8 -> заведомо вне
        XCTAssertFalse(inner.isFullyInside(outer))
    }
    
    func testZeroSizeInside() {
        let outer = aabb(SIMD2<Float>(0, 0), CGSize(width: 10, height: 10))
        // Точка в центре
        let pointCenter = aabb(SIMD2<Float>(0, 0), CGSize(width: 0, height: 0))
        XCTAssertTrue(pointCenter.isFullyInside(outer))
        
        // Точка на границе (допускается)
        let pointOnEdge = aabb(SIMD2<Float>(5, 0), CGSize(width: 0, height: 0)) // min=max=(5,0)
        XCTAssertTrue(pointOnEdge.isFullyInside(outer))
        
        // Точка вне
        let pointOutside = aabb(SIMD2<Float>(6, 0), CGSize(width: 0, height: 0))
        XCTAssertFalse(pointOutside.isFullyInside(outer))
    }
    
    func testThinLineInside() {
        let outer = aabb(SIMD2<Float>(0, 0), CGSize(width: 10, height: 10))
        // Линия по X (высота 0), полностью внутри
        let lineX = aabb(SIMD2<Float>(0, 0), CGSize(width: 8, height: 0))
        XCTAssertTrue(lineX.isFullyInside(outer))
        
        // Линия по Y (ширина 0), касается границы
        let lineYTouch = aabb(SIMD2<Float>(0, 5), CGSize(width: 0, height: 6)) // halfY=3 -> maxY = 8, ой — это вне.
        // Поправим: чтобы касалось maxY=5, halfY=3 => centerY=2
        let lineYTouchFixed = aabb(SIMD2<Float>(0, 2), CGSize(width: 0, height: 6)) // minY=-1, maxY=5
        XCTAssertTrue(lineYTouchFixed.isFullyInside(outer))
        
        // Линия выходит за предел
        let lineOutside = aabb(SIMD2<Float>(0, 3), CGSize(width: 0, height: 8)) // halfY=4 -> maxY=7 > 5
        XCTAssertFalse(lineOutside.isFullyInside(outer))
    }
}
