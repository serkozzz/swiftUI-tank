//
//  ComponentSearchTests.swift
//  UnitTests
//
//  Created by Sergey Kozlov on 05.10.2025.
//

import XCTest
import TankEngine2D
import SwiftUI

@testable import TankEngine2D

@MainActor
final class ComponentSearchTests: XCTestCase {

    // Узел должен возвращать только свои компоненты через getComponents
    func testGetComponentsOnSingleNode() {
        let scene = createScene()

        // В createScene первый потомок root уже содержит один TEGeometryObject2D
        let base = scene.rootNode.children.first!
        XCTAssertEqual(base.getComponents(TEGeometryObject2D.self).count, 1, "Должен быть один geometry‑компонент на базовом узле")
        XCTAssertEqual(base.getComponents(TEComponent2D.self).count, 1, "Все компоненты базового узла (включая geometry) должны быть найдены как TEComponent2D")

        // Добавим ещё один компонент
        let extra = TEComponent2D()
        base.attachComponent(extra)

        XCTAssertEqual(base.getComponents(TEGeometryObject2D.self).count, 1, "Количество geometry‑компонентов не меняется")
        XCTAssertEqual(base.getComponents(TEComponent2D.self).count, 2, "Теперь два компонента TEComponent2D (geometry + extra)")
        XCTAssertTrue(base.getComponents(TEComponent2D.self).contains(where: { $0 === extra }), "Новый компонент должен находиться")
    }

    // Поиск по поддереву: компоненты собираются из self и всех потомков
    func testGetAllComponentsInSubtree() {
        let scene = createScene()
        let base = scene.rootNode.children.first!

        // На базовом уже есть 1 geometry (=> 1 TEComponent2D)
        let baseExtra = TEComponent2D()
        base.attachComponent(baseExtra) // теперь на базовом 2 TEComponent2D: geometry + baseExtra

        // Добавим двух детей и внука
        let child1 = TESceneNode2D(position: .zero)
        let child2 = TESceneNode2D(position: .zero)
        base.addChild(child1)
        base.addChild(child2)

        let child1Comp = TEComponent2D()
        child1.attachComponent(child1Comp)

        let child2Geom = TEGeometryObject2D(AnyView(EmptyView()), boundingBox: .zero)
        child2.attachComponent(child2Geom) // это тоже TEComponent2D

        let grandchild = TESceneNode2D(position: .zero)
        child1.addChild(grandchild)
        let grandchildComp = TEComponent2D()
        grandchild.attachComponent(grandchildComp)

        // Подсчёт ожидаемого количества TEComponent2D в поддереве base:
        // base: 1 geometry + 1 baseExtra = 2
        // child1: 1
        // grandchild: 1
        // child2: 1 (geometry)
        // Итого: 5
        let allBaseComponents = base.getAllComponentsInSubtree(TEComponent2D.self)
        XCTAssertEqual(allBaseComponents.count, 5, "Должны собираться все компоненты из self и потомков")

        // Для TEGeometryObject2D в поддереве base ожидаем 2: на base и на child2
        let allGeometry = base.getAllComponentsInSubtree(TEGeometryObject2D.self)
        XCTAssertEqual(allGeometry.count, 2, "Должны собираться все geometry‑компоненты из self и потомков")

        
        scene.printGraph()
        // Проверим короткие свойства
        XCTAssertEqual(base.geometryObjects.count, 1, "geometryObjects эквивалентен getComponents(TEGeometryObject2D.self) для self")
        XCTAssertTrue(base.geometryObjects.first === allGeometry.first(where: { $0 === base.geometryObject }), "geometryObject должен совпадать с первым geometry‑компонентом")
    }

    // Если нет компонентов нужного типа — возвращается пустой массив
    func testEmptyResultsWhenNoSuchComponents() {
        let scene = createScene()
        let leaf = TESceneNode2D(position: .zero)
        scene.rootNode.children.first!.addChild(leaf)

        XCTAssertTrue(leaf.getComponents(TEGeometryObject2D.self).isEmpty, "На листе нет geometry‑компонентов")
        XCTAssertTrue(leaf.getAllComponentsInSubtree(TEGeometryObject2D.self).isEmpty, "И в поддереве листа их тоже нет")
    }

    // После detach компонент пропадает из результатов поиска
    func testDetachUpdatesSearchResults() {
        let scene = createScene()
        let node = TESceneNode2D(position: .zero)
        scene.rootNode.children.first!.addChild(node)

        let c = TEComponent2D()
        node.attachComponent(c)
        XCTAssertTrue(node.getComponents(TEComponent2D.self).contains(where: { $0 === c }))

        node.detachComponent(c)
        XCTAssertFalse(node.getComponents(TEComponent2D.self).contains(where: { $0 === c }), "Компонент должен исчезнуть из результатов после detach")
    }
}
