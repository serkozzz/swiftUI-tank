//
//  AABBIntersectionTests.swift
//  UnitTests
//
//  Created by Sergey Kozlov on 05.10.2025.
//

import XCTest
import simd
@testable import TankEngine2D

@MainActor
final class AABBIntersectionTests: XCTestCase {
    
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
