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
        // Arrange: создаём сцену и два объекта, которые будут пересекаться
        let scene = createScene()
        let (nodeA, _, compA) = makeBoxNode(name: "A", position: SIMD2<Float>(0, 0), size: CGSize(width: 2, height: 2))
        let (nodeB, _, compB) = makeBoxNode(name: "B", position: SIMD2<Float>(10, 0), size: CGSize(width: 2, height: 2))
        scene.rootNode.addChild(nodeA)
        scene.rootNode.addChild(nodeB)
        
        // Запускаем движок с пустой сценой
        TETankEngine2D.shared.setScene(scene: scene)
        TETankEngine2D.shared.start()
        
        // Перемещаем nodeB так, чтобы произошла коллизия с nodeA
        nodeB.transform.position = SIMD2<Float>(1, 0)
        
        // Ждём такт движка (или чуть больше) для обработки коллизии
        try? await Task.sleep(nanoseconds: 200_000_000)
        
        // Проверка: оба компонента должны зафиксировать коллизию
        XCTAssertTrue(compA.collisions.contains(where: { $0 === nodeB.collider }), "У компонента A должен быть collision с коллайдером B")
        XCTAssertTrue(compB.collisions.contains(where: { $0 === nodeA.collider }), "У компонента B должен быть collision с коллайдером A")
    }
}
