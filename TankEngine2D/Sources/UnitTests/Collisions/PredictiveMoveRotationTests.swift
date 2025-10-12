//
//  PredictiveMoveRotationTests.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 12.10.2025.
//

import XCTest
import simd
import SwiftUI
@testable import TankEngine2D

@MainActor
final class PredictiveMoveRotationTests: XCTestCase {
    
    // MARK: - Helpers
    
    private func resetEngine() {
        TETankEngine2D.shared.pause()
    }
    
    private func makeBoxNode(name: String, position: SIMD2<Float>, size: CGSize) -> (node: TESceneNode2D, collider: TECollider2D) {
        let geom = TEGeometryObject2D(
            AnyView(Rectangle().frame(width: size.width, height: size.height)),
            boundingBox: size
        )
        let collider = TECollider2D()
        let node = TESceneNode2D(position: position, debugName: name)
        node.attachComponent(geom)
        node.attachComponent(collider)
        return (node, collider)
    }
    
    // MARK: - Tests
    
    // Чистый локальный поворот под корнем: OBB поворачивается, но без смещения в данной конфигурации коллизий нет
    func testPredictiveRotate_underRoot_stableNoUnexpectedCollisions() async throws {
        resetEngine()
        let scene = createScene()
        
        // Длинный объект под корнем
        let (A, _) = makeBoxNode(name: "A", position: SIMD2<Float>(0, 0), size: CGSize(width: 200, height: 10))
        // Далеко стоящий объект
        let (B, _) = makeBoxNode(name: "B", position: SIMD2<Float>(500, 0), size: CGSize(width: 50, height: 50))
        scene.rootNode.addChild(A)
        scene.rootNode.addChild(B)
        
        TETankEngine2D.shared.reset(withScene: scene)
        TETankEngine2D.shared.start()
        
        // Предиктивный чистый поворот A на 90°: OBB повернётся, но пересечений не должно появиться
        let result = TETankEngine2D.shared.predictiveRotate(sceneNode: A, newLocalRotation: .degrees(90))
        XCTAssertTrue(result.isInsideSceneBounds)
        XCTAssertTrue(result.colliders.isEmpty, "В этой конфигурации поворот не должен порождать коллизий (объекты далеко)")
    }
    
    // Поворот родителя переносит ребёнка так, что он пересекается с соседним объектом
    func testPredictiveRotate_parentCausesChildCollision() async throws {
        resetEngine()
        let scene = createScene()
        
        // Родитель в центре, пока без поворота
        let parent = TESceneNode2D(position: SIMD2<Float>(0, 0), debugName: "Parent")
        scene.rootNode.addChild(parent)
        
        // Длинный ребёнок (палка), изначально выше по Y, чтобы при повороте родителя попасть на X
        let (child, _) = makeBoxNode(name: "Child", position: SIMD2<Float>(0, 120), size: CGSize(width: 220, height: 10))
        parent.addChild(child)
        
        // Соседний объект справа от центра, на линии Y=0
        let (target, colliderTarget) = makeBoxNode(name: "Target", position: SIMD2<Float>(110, 0), size: CGSize(width: 60, height: 60))
        scene.rootNode.addChild(target)
        
        TETankEngine2D.shared.reset(withScene: scene)
        TETankEngine2D.shared.start()
        
        // Без поворота родителя — коллизии нет
        var res = TETankEngine2D.shared.predictiveMove(sceneNode: child, newWorldPosition: child.worldTransform.position)
        XCTAssertTrue(res.isInsideSceneBounds)
        XCTAssertFalse(res.colliders.contains(where: { $0 === colliderTarget }))
        
        // Повернём РОДИТЕЛЯ на 90° по часовой предиктивно — ребёнок сместится в мировом пространстве.
        // Проверяем, что при перемещении ребёнка в мировую позицию цели мы гарантированно получим пересечение (как аппроксимация позиции после поворота).
        let rotateParentResult = TETankEngine2D.shared.predictiveRotate(sceneNode: parent, newLocalRotation: .degrees(90))
        XCTAssertTrue(rotateParentResult.isInsideSceneBounds, "Поворот родителя сам по себе остаётся в пределах сцены")
        
        res = TETankEngine2D.shared.predictiveMove(sceneNode: child, newWorldPosition: target.worldTransform.position)
        XCTAssertTrue(res.isInsideSceneBounds)
        XCTAssertTrue(res.colliders.contains(where: { $0 === colliderTarget }), "Ребёнок должен пересечься с target после поворота родителя (геометрически — попадёт на X)")
    }
    
    // Поворот родителя приводит к выходу ребёнка за границы сцены (с учётом OBB)
    func testPredictiveRotate_parentCausesChildOutOfBounds() async throws {
        resetEngine()
        let scene = createScene(sceneBounds: CGRect(x: -1000, y: -500, width: 2000, height: 1000))
        // bounds: x: -1000..1000, y: -500..500
        
        // Родитель близко к правой границе
        let parent = TESceneNode2D(position: SIMD2<Float>(950, 0), debugName: "Parent")
        scene.rootNode.addChild(parent)
        
        // Длинный ребёнок, расположенный локально по Y (чтобы после поворота родителя попасть далеко по X)
        // halfWidth = 150, halfHeight = 5; локальный Y = 400 -> после поворота на 90° центр сдвинется по X примерно на 400
        let (child, _) = makeBoxNode(name: "Child", position: SIMD2<Float>(0, 400), size: CGSize(width: 300, height: 10))
        parent.addChild(child)
        
        TETankEngine2D.shared.reset(withScene: scene)
        TETankEngine2D.shared.start()
        
        // Без поворота — внутри границ
        let resBefore = TETankEngine2D.shared.predictiveMove(sceneNode: child, newWorldPosition: child.worldTransform.position)
        XCTAssertFalse(resBefore.isInsideSceneBounds)
        
        // Предиктивно поворачиваем родителя на 90°: ребёнок сместится вправо по миру ~ на 400, что выведет его OBB за правую границу
        let rotateRes = TETankEngine2D.shared.predictiveRotate(sceneNode: parent, newLocalRotation: .degrees(90))
        XCTAssertFalse(rotateRes.isInsideSceneBounds, "После поворота родителя длинный ребёнок должен выйти за границы сцены")
    }
    
    // Комбинация: локальный поворот узла и мировое смещение — пересечение с объектом
    func testPredictiveRotate_childLocalRotationPlusWorldMove_hitsTarget() async throws {
        resetEngine()
        let scene = createScene()
        
        // Узел под корнем: длинный и тонкий
        let (A, _) = makeBoxNode(name: "A", position: SIMD2<Float>(0, 0), size: CGSize(width: 150, height: 10))
        // Цель справа
        let (B, colliderB) = makeBoxNode(name: "B", position: SIMD2<Float>(100, 0), size: CGSize(width: 60, height: 60))
        scene.rootNode.addChild(A)
        scene.rootNode.addChild(B)
        
        TETankEngine2D.shared.reset(withScene: scene)
        TETankEngine2D.shared.start()
        
        // 1) Чистый поворот A — форма повернётся, пересечений в этой конфигурации нет
        let r = TETankEngine2D.shared.predictiveRotate(sceneNode: A, newLocalRotation: .degrees(90))
        XCTAssertTrue(r.isInsideSceneBounds)
        
        // 2) Мировое смещение A к центру B — должна быть коллизия (OBB–OBB)
        let res = TETankEngine2D.shared.predictiveMove(sceneNode: A, newWorldPosition: B.worldTransform.position)
        XCTAssertTrue(res.isInsideSceneBounds)
        XCTAssertTrue(res.colliders.contains(where: { $0 === colliderB }), "После смещения узел должен пересечься с B")
    }
}
