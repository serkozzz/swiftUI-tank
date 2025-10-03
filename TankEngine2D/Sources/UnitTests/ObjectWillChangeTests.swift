
//
//  NotificationsTests.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 27.09.2025.
//

import XCTest
import TankEngine2D
import SwiftUI
import Combine

@testable import TankEngine2D

@MainActor
final class ObjectWillChangeTests: XCTestCase {
    
    var cancellables: Set<AnyCancellable> = []
    
    func testTransformNotifications() {
        let scene2D = createScene()
        
        var notificationCount = 0
    
        let firstNode = scene2D.rootNode.children.first!
        
        firstNode.transform.objectWillChange.sink { _ in
            notificationCount += 1
        }.store(in: &cancellables)
        
        
        firstNode.transform.move(SIMD2<Float>(10, 10))
        firstNode.transform.position = SIMD2<Float>(10, 10)
        
        XCTAssertEqual(notificationCount, 2, "Должна быть ровно две нотификации")
    }
    
    func testSceneNode2DNotifications() {
        let scene2D = createScene()
        
        var notificationCount = 0
    
        let firstNode = scene2D.rootNode.children.first!
        
        firstNode.objectWillChange.sink { _ in
            notificationCount += 1
        }.store(in: &cancellables)
        
        
        firstNode.transform.move(SIMD2<Float>(10, 10))
        firstNode.transform.position = SIMD2<Float>(10, 10)
        
        XCTAssertEqual(notificationCount, 2, "Должна быть ровно две нотификации")
    }
    
    
    // TEScene2D должна эмитить objectWillChange только при  добавлении/удалении нодов в дереве
    func testScene2DNotifications() {
        let scene2D = createScene()

        var notificationCount = 0
        
        scene2D.objectWillChange.sink {
            notificationCount += 1
        }.store(in: &cancellables)
    
        let firstNode = scene2D.rootNode.children.first!
        firstNode.transform.move(SIMD2<Float>(10, 10))
        firstNode.transform.position = SIMD2<Float>(10, 10)
        
        firstNode.addChild(TESceneNode2D(position: SIMD2<Float>.zero))
        
        XCTAssertEqual(notificationCount, 1, "Должна быть ровно одна нотификация")
    }
}



extension ObjectWillChangeTests {
    
    func createScene() -> TEScene2D  {
        let go = TEGeometryObject2D(AnyView(EmptyView()), boundingBox: CGSize.zero)
        
        let node: TESceneNode2D = TESceneNode2D(position: SIMD2<Float>(0, 0), component: go)
        
        
        let camera = TECamera2D()
        let scene2D = TEScene2D(camera: camera)
        scene2D.rootNode.addChild(node)
        
        return scene2D

    }
}

