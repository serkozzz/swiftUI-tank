//
//  SceneHierarchyTests.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 12.10.2025.
//

import XCTest
import TankEngine2D
import SwiftUI
import simd

@testable import TankEngine2D

@MainActor
final class SceneHierarchyTests: XCTestCase {
    
    // MARK: - Helpers
    
    private let eps: Float = 1e-4
    
    private func expectEqual(_ a: Float, _ b: Float, _ message: String = "", file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(a, b, accuracy: eps, message, file: file, line: line)
    }
    
    private func expectEqual(_ a: SIMD2<Float>, _ b: SIMD2<Float>, _ message: String = "", file: StaticString = #filePath, line: UInt = #line) {
        expectEqual(a.x, b.x, message, file: file, line: line)
        expectEqual(a.y, b.y, message, file: file, line: line)
    }
    
    private func expectEqual(_ A: Matrix, _ B: Matrix, _ message: String = "", file: StaticString = #filePath, line: UInt = #line) {
        // сравниваем поэлементно (column-major)
        expectEqual(A.columns.0.x, B.columns.0.x, message, file: file, line: line)
        expectEqual(A.columns.0.y, B.columns.0.y, message, file: file, line: line)
        expectEqual(A.columns.0.z, B.columns.0.z, message, file: file, line: line)
        
        expectEqual(A.columns.1.x, B.columns.1.x, message, file: file, line: line)
        expectEqual(A.columns.1.y, B.columns.1.y, message, file: file, line: line)
        expectEqual(A.columns.1.z, B.columns.1.z, message, file: file, line: line)
        
        expectEqual(A.columns.2.x, B.columns.2.x, message, file: file, line: line)
        expectEqual(A.columns.2.y, B.columns.2.y, message, file: file, line: line)
        expectEqual(A.columns.2.z, B.columns.2.z, message, file: file, line: line)
    }
    
    private func T(_ x: Float, _ y: Float) -> Matrix { Matrix(translation: SIMD2<Float>(x, y)) }
    private func Rcw(_ degrees: Double) -> Matrix { Matrix(clockwiseAngle: .degrees(degrees)) }
    
    // Сборка ожидаемой world-матрицы: parentWorld * local, где local уже хранит T*R
    private func compose(_ matrices: [Matrix]) -> Matrix {
        matrices.reduce(.identity, *)
    }
    
    // MARK: - Tests
    
    // Базовый кейс: 4 уровня только с трансляциями
    func testWorldTransformWithTranslationsOnly_fourLevels() {
        let scene = createScene()
        
        let A = TESceneNode2D(position: SIMD2<Float>(10, 0), debugName: "A")
        let B = TESceneNode2D(position: SIMD2<Float>(0, 20), debugName: "B")
        let C = TESceneNode2D(position: SIMD2<Float>(-5, -5), debugName: "C")
        let D = TESceneNode2D(position: SIMD2<Float>(3, 7), debugName: "D")
        
        scene.rootNode.addChild(A)
        A.addChild(B)
        B.addChild(C)
        C.addChild(D)
        
        // Ожидаемые world-матрицы: произведение переводов вдоль пути от корня
        let expectedA = compose([T(10, 0)])
        let expectedB = compose([T(10, 0), T(0, 20)])
        let expectedC = compose([T(10, 0), T(0, 20), T(-5, -5)])
        let expectedD = compose([T(10, 0), T(0, 20), T(-5, -5), T(3, 7)])
        
        expectEqual(A.worldTransform.matrix, expectedA, "A world matrix mismatch")
        expectEqual(B.worldTransform.matrix, expectedB, "B world matrix mismatch")
        expectEqual(C.worldTransform.matrix, expectedC, "C world matrix mismatch")
        expectEqual(D.worldTransform.matrix, expectedD, "D world matrix mismatch")
        
        // Проверим позиции (из колонки 2)
        expectEqual(A.worldTransform.position, SIMD2<Float>(10, 0))
        expectEqual(B.worldTransform.position, SIMD2<Float>(10, 20))
        expectEqual(C.worldTransform.position, SIMD2<Float>(5, 15))
        expectEqual(D.worldTransform.position, SIMD2<Float>(8, 22))
    }
    
    // Повороты на верхних уровнях: проверяем, что применяется T*R (column-major) и parentWorld * local
    func testWorldTransformWithRotationsOnAncestors() {
        let scene = createScene()
        
        let A = TESceneNode2D(position: SIMD2<Float>(10, 0), debugName: "A") // local = T(10,0)
        let B = TESceneNode2D(position: SIMD2<Float>(5, 0), debugName: "B")  // local = T(5,0)
        let C = TESceneNode2D(position: SIMD2<Float>(0, 2), debugName: "C")  // local = T(0,2)
        let D = TESceneNode2D(position: SIMD2<Float>(1, 0), debugName: "D")  // local = T(1,0)
        
        scene.rootNode.addChild(A)
        A.addChild(B)
        B.addChild(C)
        C.addChild(D)
        
        // Повернём A на 90° по часовой, B на 180°, C на 270° (по часовой)
        A.transform.rotate(.degrees(90))
        B.transform.rotate(.degrees(180))
        C.transform.rotate(.degrees(270))
        // D без поворота
        
        // Для ожиданий соберём вручную:
        let expectedA = compose([T(10, 0), Rcw(90)])
        let expectedB = compose([expectedA, T(5, 0), Rcw(180)])
        let expectedC = compose([expectedB, T(0, 2), Rcw(270)])
        let expectedD = compose([expectedC, T(1, 0)])
        
        expectEqual(A.worldTransform.matrix, expectedA, "A world mismatch")
        expectEqual(B.worldTransform.matrix, expectedB, "B world mismatch")
        expectEqual(C.worldTransform.matrix, expectedC, "C world mismatch")
        expectEqual(D.worldTransform.matrix, expectedD, "D world mismatch")
    }
    
    // Изменения локальных трансформов на промежуточных уровнях должны пересчитывать потомков
    func testUpdatesPropagateAfterLocalTransformChanges() {
        let scene = createScene()
        
        let A = TESceneNode2D(position: SIMD2<Float>(10, 10), debugName: "A")
        let B = TESceneNode2D(position: SIMD2<Float>(5, 0), debugName: "B")
        let C = TESceneNode2D(position: SIMD2<Float>(0, 2), debugName: "C")
        let D = TESceneNode2D(position: SIMD2<Float>(1, 0), debugName: "D")
        
        scene.rootNode.addChild(A)
        A.addChild(B)
        B.addChild(C)
        C.addChild(D)
        
        // Базовые ожидания
        var expectedD = compose([T(10,10), T(5,0), T(0,2), T(1,0)])
        expectEqual(D.worldTransform.matrix, expectedD, "Initial D mismatch")
        
        // Повернём B на 90° по часовой и сдвинем C
        B.transform.rotate(.degrees(90))
        C.transform.move(SIMD2<Float>(3, -1)) // pre-multiply T * M локально
        
        // Пересобираем ожидание:
        let expectedB = compose([T(10,10), T(5,0), Rcw(90)])
        let expectedC = compose([expectedB, T(3, 1)]) // эквивалент T(3,-1) * T(0,2)
        expectedD = compose([expectedC, T(1,0)])
        expectEqual(D.worldTransform.matrix, expectedD, "D after B rotate and C move mismatch")
        
        // Вместо замены transform целиком — меняем позицию через публичный API
        A.transform.setPosition(SIMD2<Float>(-2, 4))
        // world(B) пересоберём: T(-2,4) * [T(5,0) * R(90)]
        let expectedB2 = compose([T(-2,4), T(5,0), Rcw(90)])
        let expectedC2 = compose([expectedB2, T(3, 1)])
        let expectedD2 = compose([expectedC2, T(1,0)])
        expectEqual(B.worldTransform.matrix, expectedB2, "B after changing A position mismatch")
        expectEqual(D.worldTransform.matrix, expectedD2, "D after changing A position mismatch")
    }
    
    // Удаление и повторное добавление поддерева пересчитывает worldTransform
    func testWorldTransformAfterRemoveAndReaddSubtree() {
        let scene = createScene()
        
        let A = TESceneNode2D(position: SIMD2<Float>(10, 0), debugName: "A")
        let B = TESceneNode2D(position: SIMD2<Float>(5, 0), debugName: "B")
        let C = TESceneNode2D(position: SIMD2<Float>(0, 2), debugName: "C")
        let D = TESceneNode2D(position: SIMD2<Float>(1, 0), debugName: "D")
        
        scene.rootNode.addChild(A)
        A.addChild(B)
        B.addChild(C)
        C.addChild(D)
        
        // Повернём A, чтобы world зависел от предка
        A.transform.rotate(.degrees(90))
        
        // Базовая проверка
        let baseD = compose([T(10,0), Rcw(90), T(5,0), T(0,2), T(1,0)])
        expectEqual(D.worldTransform.matrix, baseD, "Initial D mismatch")
        
        // Удалим B (вместе с C,D), затем добавим B под root напрямую
        A.removeChild(B)
        scene.rootNode.addChild(B)
        
        // Теперь путь до D: root -> B -> C -> D
        let expectedD = compose([T(5,0), T(0,2), T(1,0)])
        expectEqual(D.worldTransform.matrix, expectedD, "D after reparenting under root mismatch")
        
        // Вернём B обратно под A
        scene.rootNode.removeChild(B)
        A.addChild(B)
        
        // Должно снова учитывать поворот A
        let expectedD2 = compose([T(10,0), Rcw(90), T(5,0), T(0,2), T(1,0)])
        expectEqual(D.worldTransform.matrix, expectedD2, "D after reparenting back under A mismatch")
    }
    
    // Проверяем, что setRotation(clockwiseAngle:) корректно перезаписывает R, сохраняя позицию, и world обновляется
    func testSetRotationOverwritesRotationKeepsPosition() {
        let scene = createScene()
        
        let A = TESceneNode2D(position: SIMD2<Float>(3, 4), debugName: "A")
        scene.rootNode.addChild(A)
        
        // move и rotate меняют локальную матрицу как R * M и T * M
        A.transform.move(SIMD2<Float>(2, -1))       // T(2,-1) * T(3,4) = T(5,3)
        A.transform.rotate(.degrees(90))            // R(90) * T(5,3)
        
        // Теперь заменим вращение напрямую (с сохранением позиции)
        let posBefore = A.transform.position
        A.transform.setRotation(clockwiseAngle: .degrees(180)) // матрица станет T(pos) * R(180)
        
        let posAfter = A.transform.position
        expectEqual(posBefore, posAfter, "setRotation must keep translation part")
        
        let expectedLocal = compose([T(posAfter.x, posAfter.y), Rcw(180)])
        let expectedWorld = expectedLocal // под root
        expectEqual(A.worldTransform.matrix, expectedWorld, "world after setRotation mismatch")
    }
}

