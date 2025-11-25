//
//  SceneDelegateTests.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 03.10.2025.
//

import XCTest
import TankEngine2D
import SwiftUI
import Combine

@testable import TankEngine2D


private class SceneDelegateRegistatrator: TEScene2DDelegate {
    
    var addNodeCallsNumber = 0
    var removeNodeCallsNumber = 0
    var attachComponentCallsNumber = 0
    var detachComponentCallsNumber = 0
    
    func teScene2D(_ scene: TankEngine2D.TEScene2D, didAddNode node: TankEngine2D.TESceneNode2D) {
        addNodeCallsNumber += 1
    }
    
    func teScene2D(_ scene: TankEngine2D.TEScene2D, willRemoveNode node: TankEngine2D.TESceneNode2D) {
        removeNodeCallsNumber += 1
    }
    
    func teScene2D(_ scene: TankEngine2D.TEScene2D, didAttachComponent component: TankEngine2D.TEComponent2D, to node: TankEngine2D.TESceneNode2D) {
        attachComponentCallsNumber += 1
    }
    
    func teScene2D(_ scene: TankEngine2D.TEScene2D, willDetachComponent component: TankEngine2D.TEComponent2D, from node: TankEngine2D.TESceneNode2D) {
        detachComponentCallsNumber += 1
    }
}

@MainActor
final class SceneDelegateTests: XCTestCase {
    
    //возвращает true, если TEAssert.precondition сработал
    private func expectTEPrecondition(_ block: () -> Void) -> Bool {
        var fired = false

        let previous = TEAssert.preconditionHandler
        TEAssert.preconditionHandler = { _, _, _, _ in
            fired = true
        }
        defer { TEAssert.preconditionHandler = previous }
        
        block()
        return fired
    }
    
    func testDelegateCalls() {
        let scene = createScene()
        let registrator = SceneDelegateRegistatrator()
        scene.innerDelegate = registrator
        
        let node1 = TESceneNode2D(position: SIMD2<Float>.zero)
        node1.attachComponent(TEComponent2D())
    
        scene.rootNode.children.first!.addChild(node1)
        node1.addChild(TESceneNode2D(position: SIMD2<Float>.zero))
        node1.addChild(TESceneNode2D(position: SIMD2<Float>.zero))
        
        XCTAssertEqual(registrator.addNodeCallsNumber, 3, "Должна быть ровно 3 нотификации")
        XCTAssertEqual(registrator.removeNodeCallsNumber, 0, "Должна быть ровно 0 нотификации")
        XCTAssertEqual(registrator.attachComponentCallsNumber, 0, "Должна быть ровно 0 нотификации")
        XCTAssertEqual(registrator.detachComponentCallsNumber, 0, "Должна быть ровно 0 нотификации")
        
        let testComponent = TEComponent2D()
        node1.attachComponent(testComponent)
        node1.attachComponent(TEComponent2D())
        node1.detachComponent(testComponent)
        
        
        XCTAssertEqual(registrator.addNodeCallsNumber, 3, "Должна быть ровно 3 нотификации")
        XCTAssertEqual(registrator.removeNodeCallsNumber, 0, "Должна быть ровно 1 нотификации")
        XCTAssertEqual(registrator.attachComponentCallsNumber, 2, "Должна быть ровно 0 нотификации")
        XCTAssertEqual(registrator.detachComponentCallsNumber, 1, "Должна быть ровно 0 нотификации")
        
        node1.parent!.removeChild(node1)
        
        XCTAssertEqual(registrator.addNodeCallsNumber, 3, "Должна быть ровно 3 нотификации")
        XCTAssertEqual(registrator.removeNodeCallsNumber, 1, "Должна быть ровно 1 нотификации")
        XCTAssertEqual(registrator.attachComponentCallsNumber, 2, "Должна быть ровно 0 нотификации")
        XCTAssertEqual(registrator.detachComponentCallsNumber, 1, "Должна быть ровно 0 нотификации")
    }
    
 
}

