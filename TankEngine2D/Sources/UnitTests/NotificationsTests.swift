
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

final class NotificationsTests: XCTestCase {
    
    var cancellables: Set<AnyCancellable> = []
    
    func testSceneNode2DNotifications() {
        let scene2D = createScene()
        
        let expectation = XCTestExpectation(description: "Ожидание objectWillChange")
        var notificationCount = 0
        
//        scene2D.objectWillChange.sink {
//            notificationCount += 1
//            expectation.fulfill()
//        }.store(in: &cancellables)
    
        let firstNode = scene2D.nodes.first!
        
        firstNode.transform.objectWillChange.sink { _ in
            notificationCount += 1
            expectation.fulfill()
        }.store(in: &cancellables)
        
        
        firstNode.transform.move(SIMD2<Float>(10, 10))
        firstNode.transform.position = SIMD2<Float>(10, 10)
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(notificationCount, 2, "Должна быть ровно две нотификации")
    }
    
    func testScene2DNotifications() {
        let scene2D = createScene()
        
        let expectation = XCTestExpectation(description: "Ожидание objectWillChange")
        var notificationCount = 0
        
        scene2D.objectWillChange.sink {
            notificationCount += 1
            expectation.fulfill()
        }.store(in: &cancellables)
    
        let firstNode = scene2D.nodes.first!
        firstNode.transform.move(SIMD2<Float>(10, 10))
        firstNode.transform.position = SIMD2<Float>(10, 10)
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(notificationCount, 2, "Должна быть ровно две нотификации")
    }
}



extension NotificationsTests {
    
    func createScene() -> TEScene2D  {
        let nodes: [TESceneNode2D] = [TESceneNode2D(position: SIMD2<Float>(0, 0))]
        
        let camera = TECamera2D()
        let scene2D = TEScene2D(nodes: nodes, camera: camera)
        
        return scene2D

    }
}

