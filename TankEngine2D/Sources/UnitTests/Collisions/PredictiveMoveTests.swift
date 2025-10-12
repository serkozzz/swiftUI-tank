//
//  PredictiveMoveTests.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 12.10.2025.
//

import XCTest
import simd
import SwiftUI
@testable import TankEngine2D

@MainActor
final class PredictiveMoveTests: XCTestCase {
    
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
    
    // Без пересечений, внутри границ сцены
    func testPredictiveMove_noCollision_insideBounds() async throws {
        resetEngine()
        let scene = createScene()
        
        // Ставим два объекта далеко друг от друга
        let (A, _) = makeBoxNode(name: "A", position: SIMD2<Float>(0, 0), size: CGSize(width: 10, height: 10))
        let (B, _) = makeBoxNode(name: "B", position: SIMD2<Float>(200, 0), size: CGSize(width: 10, height: 10))
        scene.rootNode.addChild(A)
        scene.rootNode.addChild(B)
        
        TETankEngine2D.shared.reset(withScene: scene)
        TETankEngine2D.shared.start()
        
        // Пробуем переместить A ближе, но всё ещё далеко от B (локальная позиция у корневого ребёнка == мировой)
        let newLocal = TETransform2D(position: SIMD2<Float>(50, 0))
        let result = TETankEngine2D.shared.predictiveMove(sceneNode: A, newLocalTransform: newLocal)
        
        XCTAssertTrue(result.isInsideSceneBounds, "Должны оставаться в пределах сцены")
        XCTAssertTrue(result.colliders.isEmpty, "Не должно быть пересечений")
    }
    
    // Пересечение с другим коллайдером
    func testPredictiveMove_detectsCollision() async throws {
        resetEngine()
        let scene = createScene()
        
        let (A, _) = makeBoxNode(name: "A", position: SIMD2<Float>(0, 0), size: CGSize(width: 10, height: 10))
        let (B, colliderB) = makeBoxNode(name: "B", position: SIMD2<Float>(30, 0), size: CGSize(width: 10, height: 10))
        scene.rootNode.addChild(A)
        scene.rootNode.addChild(B)
        
        TETankEngine2D.shared.reset(withScene: scene)
        TETankEngine2D.shared.start()
        
        // Перенесём A так, чтобы он пересёкся с B
        let newLocal = TETransform2D(position: SIMD2<Float>(30, 0))
        let result = TETankEngine2D.shared.predictiveMove(sceneNode: A, newLocalTransform: newLocal)
        
        XCTAssertTrue(result.isInsideSceneBounds, "Должны оставаться в пределах сцены")
        XCTAssertTrue(result.colliders.contains(where: { $0 === colliderB }), "Должен обнаружиться коллайдер B")
    }
    
    // Выход за границы сцены
    func testPredictiveMove_outOfBounds() async throws {
        resetEngine()
        let scene = createScene() // bounds: x: -1000..1000, y: -500..500
        
        let (A, _) = makeBoxNode(name: "A", position: SIMD2<Float>(0, 0), size: CGSize(width: 50, height: 50))
        scene.rootNode.addChild(A)
        
        TETankEngine2D.shared.reset(withScene: scene)
        TETankEngine2D.shared.start()
        
        // Сместим далеко за пределы сцены
        let newLocal = TETransform2D(position: SIMD2<Float>(5000, 5000))
        let result = TETankEngine2D.shared.predictiveMove(sceneNode: A, newLocalTransform: newLocal)
        
        XCTAssertFalse(result.isInsideSceneBounds, "Перемещение должно выходить за пределы сцены")
        XCTAssertTrue(result.colliders.isEmpty, "Пересечений с другими коллайдерами нет")
    }
    
    // Иерархия: используем мировую перегрузку, чтобы исключить путаницу локальных осей при повороте родителя
    func testPredictiveMove_withParentTransformHierarchy() async throws {
        resetEngine()
        let scene = createScene()
        
        // Родитель с поворотом и трансляцией
        let parent = TESceneNode2D(position: SIMD2<Float>(100, 0), debugName: "Parent")
        scene.rootNode.addChild(parent)
        parent.transform.rotate(.degrees(90)) // поворот по часовой
        
        // Ребёнок с коллайдером
        let (child, _) = makeBoxNode(name: "Child", position: SIMD2<Float>(0, 20), size: CGSize(width: 10, height: 10))
        parent.addChild(child)
        
        // Отдельный стационарный объект в мировой системе
        let (target, colliderTarget) = makeBoxNode(name: "Target", position: SIMD2<Float>(80, 20), size: CGSize(width: 10, height: 10))
        scene.rootNode.addChild(target)
        
        TETankEngine2D.shared.reset(withScene: scene)
        TETankEngine2D.shared.start()
        
        // 1) Проверка без смещения: не должно быть коллизии
        var result = TETankEngine2D.shared.predictiveMove(sceneNode: child, newWorldPosition: child.worldTransform.position)
        XCTAssertTrue(result.isInsideSceneBounds)
        XCTAssertFalse(result.colliders.contains(where: { $0 === colliderTarget }))
        
        // 2) Перемещаем ребёнка в мировую позицию target — должна быть коллизия
        result = TETankEngine2D.shared.predictiveMove(sceneNode: child, newWorldPosition: target.worldTransform.position)
        XCTAssertTrue(result.isInsideSceneBounds)
        XCTAssertTrue(result.colliders.contains(where: { $0 === colliderTarget }), "Должны столкнуться с target с учётом родительского world-трансформа")
    }
    
    // После detach коллайдера — predictiveMove больше его не возвращает
    func testPredictiveMove_afterColliderDetached() async throws {
        resetEngine()
        let scene = createScene()
        
        let (A, _) = makeBoxNode(name: "A", position: SIMD2<Float>(0, 0), size: CGSize(width: 10, height: 10))
        let (B, colliderB) = makeBoxNode(name: "B", position: SIMD2<Float>(10, 0), size: CGSize(width: 10, height: 10))
        scene.rootNode.addChild(A)
        scene.rootNode.addChild(B)
        
        TETankEngine2D.shared.reset(withScene: scene)
        TETankEngine2D.shared.start()
        
        // Проверим, что при перемещении A в позицию B будет коллизия
        var result = TETankEngine2D.shared.predictiveMove(sceneNode: A, newLocalTransform: TETransform2D(position: SIMD2<Float>(10, 0)))
        XCTAssertTrue(result.colliders.contains(where: { $0 === colliderB }))
        
        // Отсоединяем коллайдер у B
        B.detachComponent(colliderB)
        
        // Повторяем predictiveMove — colliderB больше не должен участвовать
        result = TETankEngine2D.shared.predictiveMove(sceneNode: A, newLocalTransform: TETransform2D(position: SIMD2<Float>(10, 0)))
        XCTAssertFalse(result.colliders.contains(where: { $0 === colliderB }), "После detach коллайдер больше не должен попадать в результат")
    }
}

// MARK: - Проверка перегрузок predictiveMove/predictiveRotate
@MainActor
extension PredictiveMoveTests {
    
    func testOverloads_localTransform_vs_localPosition_and_localDelta() async throws {
        resetEngine()
        let scene = createScene()
        let (A, _) = makeBoxNode(name: "A", position: SIMD2<Float>(0, 0), size: CGSize(width: 10, height: 10))
        scene.rootNode.addChild(A)
        TETankEngine2D.shared.reset(withScene: scene)
        TETankEngine2D.shared.start()
        
        // Цель: (15, 5) в локальных (== мировых для корневого ребёнка)
        let target = SIMD2<Float>(15, 5)
        
        let viaLocalTransform = TETankEngine2D.shared.predictiveMove(sceneNode: A, newLocalTransform: TETransform2D(position: target))
        let viaLocalPosition  = TETankEngine2D.shared.predictiveMove(sceneNode: A, newLocalPosition: target)
        let viaLocalDelta     = TETankEngine2D.shared.predictiveMove(sceneNode: A, localDelta: target - A.transform.position)
        
        XCTAssertEqual(viaLocalTransform.isInsideSceneBounds, viaLocalPosition.isInsideSceneBounds)
        XCTAssertEqual(viaLocalTransform.isInsideSceneBounds, viaLocalDelta.isInsideSceneBounds)
        XCTAssertEqual(viaLocalTransform.colliders.count, viaLocalPosition.colliders.count)
        XCTAssertEqual(viaLocalTransform.colliders.count, viaLocalDelta.colliders.count)
    }
    
    func testOverloads_worldTransform_vs_worldPosition_and_worldDelta() async throws {
        resetEngine()
        let scene = createScene()
        let (A, _) = makeBoxNode(name: "A", position: SIMD2<Float>(10, 10), size: CGSize(width: 10, height: 10))
        scene.rootNode.addChild(A)
        TETankEngine2D.shared.reset(withScene: scene)
        TETankEngine2D.shared.start()
        
        // Мировая цель: (50, -20)
        let targetWorld = SIMD2<Float>(50, -20)
        
        let viaWorldTransform = TETankEngine2D.shared.predictiveMove(sceneNode: A, newWorldTransform: TETransform2D(position: targetWorld))
        let viaWorldPosition  = TETankEngine2D.shared.predictiveMove(sceneNode: A, newWorldPosition: targetWorld)
        let viaWorldDelta     = TETankEngine2D.shared.predictiveMove(sceneNode: A, worldDelta: targetWorld - A.worldTransform.position)
        
        XCTAssertEqual(viaWorldTransform.isInsideSceneBounds, viaWorldPosition.isInsideSceneBounds)
        XCTAssertEqual(viaWorldTransform.isInsideSceneBounds, viaWorldDelta.isInsideSceneBounds)
        XCTAssertEqual(viaWorldTransform.colliders.count, viaWorldPosition.colliders.count)
        XCTAssertEqual(viaWorldTransform.colliders.count, viaWorldDelta.colliders.count)
    }
    
    func testOverloads_local_vs_world_equivalence_under_root() async throws {
        resetEngine()
        let scene = createScene()
        let (A, _) = makeBoxNode(name: "A", position: SIMD2<Float>(0, 0), size: CGSize(width: 10, height: 10))
        scene.rootNode.addChild(A)
        TETankEngine2D.shared.reset(withScene: scene)
        TETankEngine2D.shared.start()
        
        // Под корнем локальные == мировые
        let target = SIMD2<Float>(25, 30)
        let localRes = TETankEngine2D.shared.predictiveMove(sceneNode: A, newLocalTransform: TETransform2D(position: target))
        let worldRes = TETankEngine2D.shared.predictiveMove(sceneNode: A, newWorldTransform: TETransform2D(position: target))
        
        XCTAssertEqual(localRes.isInsideSceneBounds, worldRes.isInsideSceneBounds)
        XCTAssertEqual(localRes.colliders.count, worldRes.colliders.count)
    }
    
    func testOverloads_predictiveRotate_variants() async throws {
        resetEngine()
        let scene = createScene()
        let (A, _) = makeBoxNode(name: "A", position: SIMD2<Float>(0, 0), size: CGSize(width: 20, height: 20))
        scene.rootNode.addChild(A)
        TETankEngine2D.shared.reset(withScene: scene)
        TETankEngine2D.shared.start()
        
        // Повороты AABB не меняют форму (ось-выравненно), но API должен стабильно работать
        let r1 = TETankEngine2D.shared.predictiveRotate(sceneNode: A, newLocalRotation: .degrees(45))
        let r2 = TETankEngine2D.shared.predictiveRotate(sceneNode: A, localDeltaRotation: .degrees(45))
        
        XCTAssertTrue(r1.isInsideSceneBounds)
        XCTAssertTrue(r2.isInsideSceneBounds)
        XCTAssertEqual(r1.colliders.count, r2.colliders.count)
    }
    
    func testOverloads_worldPosition_with_parent_hierarchy() async throws {
        resetEngine()
        let scene = createScene()
        
        // Родитель с поворотом и смещением
        let parent = TESceneNode2D(position: SIMD2<Float>(100, 0))
        scene.rootNode.addChild(parent)
        parent.transform.rotate(.degrees(90))
        
        // Дети
        let (child, _) = makeBoxNode(name: "Child", position: SIMD2<Float>(0, 20), size: CGSize(width: 10, height: 10))
        let (target, colliderTarget) = makeBoxNode(name: "Target", position: SIMD2<Float>(80, 20), size: CGSize(width: 10, height: 10))
        parent.addChild(child)
        scene.rootNode.addChild(target)
        
        TETankEngine2D.shared.reset(withScene: scene)
        TETankEngine2D.shared.start()
        
        // Прямая проверка мировой перегрузки
        let resNoMove = TETankEngine2D.shared.predictiveMove(sceneNode: child, newWorldPosition: child.worldTransform.position)
        XCTAssertTrue(resNoMove.isInsideSceneBounds)
        XCTAssertFalse(resNoMove.colliders.contains(where: { $0 === colliderTarget }))
        
        let resHit = TETankEngine2D.shared.predictiveMove(sceneNode: child, newWorldPosition: target.worldTransform.position)
        XCTAssertTrue(resHit.isInsideSceneBounds)
        XCTAssertTrue(resHit.colliders.contains(where: { $0 === colliderTarget }))
    }
}
