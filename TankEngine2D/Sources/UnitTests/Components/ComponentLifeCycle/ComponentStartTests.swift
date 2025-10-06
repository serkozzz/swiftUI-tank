//
//  ComponentStartTests.swift
//  UnitTests
//
//  Created by Sergey Kozlov on 05.10.2025.
//

import XCTest
import TankEngine2D
import SwiftUI

@testable import TankEngine2D


@MainActor
final class ComponentStartTests: XCTestCase {
    
    private func resetEngine() {
        // На всякий случай останавливаем предыдущее состояние между тестами.
        TETankEngine2D.shared.pause()
    }
    
    // 3) Компонент уже в сцене, движок стартует — start вызывается один раз.
    func testStartOnEngineStartForExistingComponents() {
        resetEngine()
        let scene = createScene()
        
        let baseNode = TESceneNode2D(position: SIMD2<Float>.zero, debugName: "baseNode")
        let component = ComponentSpy()
        baseNode.attachComponent(component)
        scene.rootNode.addChild(baseNode)
        
        XCTAssertEqual(component.startsNumber, 0, "До старта движка start вызываться не должен")
        
        TETankEngine2D.shared.setScene(scene: scene)
        TETankEngine2D.shared.start()
        
        XCTAssertEqual(component.startsNumber, 1, "При старте движка компонент должен стартовать один раз")
    }
    
    // 1) attach к живому узлу — start вызывается один раз.
    func testStartOnAttachToLiveNode() {
        resetEngine()
        let scene = createScene()
        TETankEngine2D.shared.setScene(scene: scene)
        TETankEngine2D.shared.start()
        
        let liveNode = TESceneNode2D(position: .zero, debugName: "liveNode")
        scene.rootNode.addChild(liveNode) // узел уже в живом дереве
        
        let component = ComponentSpy()
        XCTAssertEqual(component.startsNumber, 0)
        
        liveNode.attachComponent(component) // attach к живому узлу
        XCTAssertEqual(component.startsNumber, 1, "При attach к живому узлу компонент должен стартовать один раз")
    }
    
    // 2) Присоединение поддерева с компонентом к живому дереву — start вызывается один раз.
    func testStartOnSubtreeAttachToLiveTree() {
        resetEngine()
        let scene = createScene()
        TETankEngine2D.shared.setScene(scene: scene)
        TETankEngine2D.shared.start()
        
        // Узел вне сцены с уже прикреплённым компонентом
        let detachedNode = TESceneNode2D(position: .zero, debugName: "detachedNode")
        let component = ComponentSpy()
        detachedNode.attachComponent(component)
        XCTAssertEqual(component.startsNumber, 0, "Пока узел не в живом дереве — start не должен вызываться")
        
        // Присоединяем поддерево к живой сцене
        scene.rootNode.addChild(detachedNode)
        XCTAssertEqual(component.startsNumber, 1, "При присоединении поддерева к живому дереву компонент должен стартовать один раз")
    }
    
    // После первого старта: отсоединили поддерево и присоединили снова — повторного старта НЕ будет.
    func testNoSecondStartOnDetachAndReattachSubtree() {
        resetEngine()
        let scene = createScene()
        TETankEngine2D.shared.setScene(scene: scene)
        TETankEngine2D.shared.start()
        
        let node = TESceneNode2D(position: .zero, debugName: "node")
        let component = ComponentSpy()
        node.attachComponent(component)     // пока вне дерева
        scene.rootNode.addChild(node)       // первый вход в живую сцену
        XCTAssertEqual(component.startsNumber, 1, "Первое попадание в живую сцену должно вызвать start один раз")
        
        // Отсоединяем поддерево и присоединяем снова
        scene.rootNode.removeChild(node)
        XCTAssertEqual(component.startsNumber, 1, "Отсоединение не должно вызывать повторных стартов")
        
        scene.rootNode.addChild(node)
        XCTAssertEqual(component.startsNumber, 1, "Повторное присоединение поддерева не должно давать второй start")
    }
    
    // Повторный старт движка с той же сценой НЕ вызывает повторных start у уже стартовавших компонентов.
    func testNoSecondStartOnEngineRestart() {
        resetEngine()
        let scene = createScene()
        
        let node = TESceneNode2D(position: .zero, debugName: "node")
        let component = ComponentSpy()
        node.attachComponent(component)
        scene.rootNode.addChild(node)
        
        TETankEngine2D.shared.setScene(scene: scene)
        TETankEngine2D.shared.start()
        XCTAssertEqual(component.startsNumber, 1, "Первый старт движка должен вызвать start один раз")
        
        // Перезапускаем движок с той же сценой
        TETankEngine2D.shared.pause()
        TETankEngine2D.shared.setScene(scene: scene)
        TETankEngine2D.shared.start()
        
        XCTAssertEqual(component.startsNumber, 1, "Повторный старт движка с той же сценой не должен вызывать повторный start")
    }
    
    // Компонент прикреплён, когда движок не запущен — start не вызывается до старта движка.
    func testAttachWhilePausedThenStart() {
        resetEngine()
        let scene = createScene()
        TETankEngine2D.shared.setScene(scene: scene) // движок ещё не стартовал
        
        let node = TESceneNode2D(position: .zero, debugName: "node")
        scene.rootNode.addChild(node)
        
        let component = ComponentSpy()
        node.attachComponent(component) // узел в дереве, но движок не стартовал
        XCTAssertEqual(component.startsNumber, 0, "Без запущенного движка start вызываться не должен")
        
        TETankEngine2D.shared.start()
        XCTAssertEqual(component.startsNumber, 1, "После старта движка компонент должен стартовать один раз")
    }
}
