//
//  ComponentCollisionIntegrationTests.swift
//  UnitTests
//
//  Created by Sergey Kozlov on 06.10.2025.
//

import XCTest
import TankEngine2D
import SwiftUI

@testable import TankEngine2D

@MainActor
final class ComponentCollisionIntegrationTests: XCTestCase {
    
    final class ComponentSpy: TEComponent2D {
        var collisions: [TECollider2D] = []
        override func collision(collider: TECollider2D) {
            collisions.append(collider)
        }
    }
    
    func makeBoxNode(name: String, position: SIMD2<Float>, size: CGSize) -> (TESceneNode2D, TECollider2D, ComponentSpy) {
        let geom = TEGeometryObject2D(
            AnyView(Rectangle().frame(width: size.width, height: size.height)),
            boundingBox: size
        )
        let collider = TECollider2D()
        let spy = ComponentSpy()
        let node = TESceneNode2D(position: position, debugName: name)
        node.attachComponent(geom)
        node.attachComponent(collider)
        node.attachComponent(spy)
        return (node, collider, spy)
    }
    
    func testCollisionLifecycleViaRealEngine() async {
        let scene = createScene()
        let (nodeA, _, compA) = makeBoxNode(name: "A", position: SIMD2<Float>(0, 0), size: CGSize(width: 2, height: 2))
        let (nodeB, _, compB) = makeBoxNode(name: "B", position: SIMD2<Float>(10, 0), size: CGSize(width: 2, height: 2))
        scene.rootNode.addChild(nodeA)
        scene.rootNode.addChild(nodeB)
        
        TETankEngine2D.shared.setScene(scene: scene)
        TETankEngine2D.shared.start()
        
        nodeB.transform.position = SIMD2<Float>(1, 0)
        try? await Task.sleep(nanoseconds: 200_000_000)
        
        XCTAssertTrue(compA.collisions.contains(where: { $0 === nodeB.collider }), "A должен получить коллизию с B")
        XCTAssertTrue(compB.collisions.contains(where: { $0 === nodeA.collider }), "B должен получить коллизию с A")
    }
    
    func testNoCollisionIfNoIntersection() async {
        let scene = createScene()
        let (nodeA, _, compA) = makeBoxNode(name: "A", position: SIMD2<Float>(0, 0), size: CGSize(width: 2, height: 2))
        let (nodeB, _, compB) = makeBoxNode(name: "B", position: SIMD2<Float>(100, 0), size: CGSize(width: 2, height: 2))
        scene.rootNode.addChild(nodeA)
        scene.rootNode.addChild(nodeB)
        
        TETankEngine2D.shared.setScene(scene: scene)
        TETankEngine2D.shared.start()
        
        try? await Task.sleep(nanoseconds: 200_000_000)
        
        XCTAssertTrue(compA.collisions.isEmpty, "A не должен получать коллизий")
        XCTAssertTrue(compB.collisions.isEmpty, "B не должен получать коллизий")
    }
    
    func testNoCollisionAfterColliderDetached() async {
        let scene = createScene()
        let (nodeA, _, compA) = makeBoxNode(name: "A", position: SIMD2<Float>(0, 0), size: CGSize(width: 2, height: 2))
        let (nodeB, colliderB, compB) = makeBoxNode(name: "B", position: SIMD2<Float>(1, 0), size: CGSize(width: 2, height: 2))
        scene.rootNode.addChild(nodeA)
        scene.rootNode.addChild(nodeB)
        
        TETankEngine2D.shared.setScene(scene: scene)
        TETankEngine2D.shared.start()
        try? await Task.sleep(nanoseconds: 200_000_000)
        
        compA.collisions.removeAll()
        compB.collisions.removeAll()
        nodeB.detachComponent(colliderB)
        nodeB.transform.position = SIMD2<Float>(0, 0) // всё равно пересечение
        
        try? await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertTrue(compA.collisions.isEmpty, "A не должен получать collision после detach коллайдера B")
        XCTAssertTrue(compB.collisions.isEmpty, "B не должен получать collision после detach своего коллайдера")
    }
    
    func testCollisionAfterDetachAndReattachNode() async {
        let scene = createScene()
        let (nodeA, colliderA, compA) = makeBoxNode(name: "A", position: SIMD2<Float>(0, 0), size: CGSize(width: 2, height: 2))
        let (nodeB, colliderB, compB) = makeBoxNode(name: "B", position: SIMD2<Float>(1, 0), size: CGSize(width: 2, height: 2))
        scene.rootNode.addChild(nodeA)
        scene.rootNode.addChild(nodeB)
        
        TETankEngine2D.shared.setScene(scene: scene)
        TETankEngine2D.shared.start()
        try? await Task.sleep(nanoseconds: 200_000_000)
        
        scene.rootNode.removeChild(nodeB)
        compA.collisions.removeAll()
        compB.collisions.removeAll()
        
        scene.rootNode.addChild(nodeB)
        nodeB.transform.position = SIMD2<Float>(0, 0) // гарантированно пересекается с A
        
        try? await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertTrue(compA.collisions.contains(where: { $0 === colliderB }), "A должен снова получать collision после повторного addChild(B)")
        XCTAssertTrue(compB.collisions.contains(where: { $0 === colliderA }), "B должен снова получать collision после повторного addChild(B)")
    }
    
    func testCollisionAfterAttachingSubtreeWithColliders() async {
        let scene = createScene()
        let (nodeA, colliderA, compA) = makeBoxNode(name: "A", position: SIMD2<Float>(0, 0), size: CGSize(width: 2, height: 2))
        scene.rootNode.addChild(nodeA)
        
        // Поддерево вне сцены
        let subtree = TESceneNode2D(position: SIMD2<Float>(1, 0), debugName: "subtree")
        let colliderB = TECollider2D()
        let compB = ComponentSpy()
        let geomB = TEGeometryObject2D(AnyView(Rectangle().frame(width: 2, height: 2)), boundingBox: CGSize(width: 2, height: 2))
        subtree.attachComponent(geomB)
        subtree.attachComponent(colliderB)
        subtree.attachComponent(compB)
        
        TETankEngine2D.shared.setScene(scene: scene)
        TETankEngine2D.shared.start()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Добавляем поддерево уже с коллайдером
        scene.rootNode.addChild(subtree)
        try? await Task.sleep(nanoseconds: 300_000_000)
        
        XCTAssertTrue(compA.collisions.contains(where: { $0 === colliderB }), "A должен получить collision, когда поддерево с коллайдером появилось")
        XCTAssertTrue(compB.collisions.contains(where: { $0 === colliderA }), "Коллайдер поддерева должен получить collision c A")
    }
}
