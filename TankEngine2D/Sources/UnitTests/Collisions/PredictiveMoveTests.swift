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
        
        // Пробуем переместить A ближе, но всё ещё далеко от B
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
    
    // Иерархия: перемещение дочернего узла учитывает world предка (parentWorld * local)
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
        var result = TETankEngine2D.shared.predictiveMove(sceneNode: child, newLocalTransform: TETransform2D(child.transform))
        XCTAssertTrue(result.isInsideSceneBounds)
        
        // 2) Смещаем локально так, чтобы оказаться ближе к target: локальное смещение по Y на -20 должно сдвинуть мировую позицию влево по X
        let movedLocal = TETransform2D(child.transform)
        movedLocal.move(SIMD2<Float>(0, -20))
        result = TETankEngine2D.shared.predictiveMove(sceneNode: child, newLocalTransform: movedLocal)
        
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
        
        // Отсоединяем коллайдер у B и повторяем
        B.detachComponent(colliderB)
        result = TETankEngine2D.shared.predictiveMove(sceneNode: A, newLocalTransform: TETransform2D(position: SIMD2<Float>(10, 0)))
        XCTAssertFalse(result.colliders.contains(where: { $0 === colliderB }), "После detach коллайдер больше не должен попадать в результат")
    }
}

