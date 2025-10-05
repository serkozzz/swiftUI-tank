//
//  ComponentAttachmentPreconditionTests.swift
//  UnitTests
//
//  Created by Sergey Kozlov on 05.10.2025.
//

import XCTest
import TankEngine2D

@testable import TankEngine2D

@MainActor
final class ComponentAttachmentPreconditionTests: XCTestCase {

    // Возвращает true, если TEAssert.precondition сработал в блоке.
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

    // Нельзя прикрепить один и тот же компонент ко второму узлу, пока он прикреплён к первому.
    func testAttachSameComponentToSecondNodeFiresPrecondition() {
        let scene = createScene()
        TETankEngine2D.shared.setScene(scene: scene)
        TETankEngine2D.shared.start()

        let node1 = TESceneNode2D(position: .zero)
        let node2 = TESceneNode2D(position: .zero)

        // Включаем узлы в дерево сцены, как в ваших примерах
        scene.rootNode.children.first!.addChild(node1)
        scene.rootNode.children.first!.addChild(node2)

        let component = TEComponent2D()
        node1.attachComponent(component)

        let fired = expectTEPrecondition {
            node2.attachComponent(component) // нарушает инвариант (owner уже установлен)
        }
        XCTAssertTrue(fired, "Должен сработать TEAssert.precondition при попытке attach к другому узлу без detach")
    }

    // Повторный attach того же компонента к тому же узлу без detach — тоже ошибка.
    func testReattachSameComponentToSameNodeFiresPrecondition() {
        let scene = createScene()
        TETankEngine2D.shared.setScene(scene: scene)
        TETankEngine2D.shared.start()

        let node = TESceneNode2D(position: .zero)
        scene.rootNode.children.first!.addChild(node)

        let component = TEComponent2D()
        node.attachComponent(component)

        let fired = expectTEPrecondition {
            node.attachComponent(component) // повторный attach того же компонента
        }
        XCTAssertTrue(fired, "Повторный attach одного и того же компонента к тому же узлу должен ронять precondition")
    }

    // Базовый кейс: новый компонент можно прикрепить к узлу — precondition НЕ должен срабатывать.
    func testAttachFreshComponentDoesNotFirePrecondition() {
        let scene = createScene()

        let node = TESceneNode2D(position: .zero)
        scene.rootNode.children.first!.addChild(node)

        let component = TEComponent2D()
        let fired = expectTEPrecondition {
            node.attachComponent(component) // корректный первый attach
        }
        XCTAssertFalse(fired, "Не должен срабатывать precondition при первом корректном attach")
    }

    // После detach — повторный attach запрещён (компонент уже «стартовал»), должен сработать precondition.
    func testDetachThenAttachAgainStillFiresPrecondition() {
        let scene = createScene()
        TETankEngine2D.shared.setScene(scene: scene)
        TETankEngine2D.shared.start()

        let node1 = TESceneNode2D(position: .zero)
        let node2 = TESceneNode2D(position: .zero)
        scene.rootNode.children.first!.addChild(node1)
        scene.rootNode.children.first!.addChild(node2)

        let component = TEComponent2D()
        node1.attachComponent(component)
        node1.detachComponent(component)

        let fired = expectTEPrecondition {
            node2.attachComponent(component) // повторный attach после detach запрещён
        }
        XCTAssertTrue(fired, "После detach повторный attach должен ронять precondition (forbidden to reattach components)")
    }
}
