//
//  Scene2D+PrintGraph.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 05.10.2025.
//

import Foundation

public enum TESceneGraphStyle {
    case unicode         // ├──, └──, │
    case ascii           // +--, `--, |
    case pipeUnderscore  // |____, \____, |
}

@MainActor
public extension TEScene2D {
    
    // Печать всей сцены (от корня)
    func printGraph(style: TESceneGraphStyle = .unicode) {
        print(graphDescription(style: style))
    }
    
    // Строковое описание всей сцены (от корня)
    func graphDescription(style: TESceneGraphStyle = .unicode) -> String {
        let tokens = _TreeTokens(style: style)
        var lines: [String] = ["root"]
        let children = rootNode.children
        for (idx, child) in children.enumerated() {
            let isLast = idx == children.count - 1
            lines.append(contentsOf: child._graphLines(prefix: "", isLast: isLast, tokens: tokens))
        }
        return lines.joined(separator: "\n")
    }
    
    // Печать поддерева от конкретного узла
    func printSubtree(from node: TESceneNode2D, style: TESceneGraphStyle = .unicode) {
        print(subtreeDescription(from: node, style: style))
    }
    
    // Строковое описание поддерева от конкретного узла
    func subtreeDescription(from node: TESceneNode2D, style: TESceneGraphStyle = .unicode) -> String {
        let tokens = _TreeTokens(style: style)
        var lines: [String] = [node._rootLine(tokens: tokens)]
        let children = node.children
        for (idx, child) in children.enumerated() {
            let isLast = idx == children.count - 1
            lines.append(contentsOf: child._graphLines(prefix: "", isLast: isLast, tokens: tokens))
        }
        return lines.joined(separator: "\n")
    }
}

// Маркеры для разных стилей отрисовки дерева
fileprivate struct _TreeTokens {
    let branch: String
    let lastBranch: String
    let vertical: String
    let space: String
    
    init(style: TESceneGraphStyle) {
        switch style {
        case .unicode:
            self.branch = "├── "
            self.lastBranch = "└── "
            self.vertical = "│   "
            self.space = "    "
        case .ascii:
            self.branch = "+-- "
            self.lastBranch = "`-- "
            self.vertical = "|   "
            self.space = "    "
        case .pipeUnderscore:
            self.branch = "|____ "
            self.lastBranch = "\\____ "
            self.vertical = "|     "
            self.space = "      "
        }
    }
}

@MainActor
extension TESceneNode2D {
    
    // Первая строка для поддерева: сам узел без соединителей
    fileprivate func _rootLine(tokens: _TreeTokens) -> String {
        let label = _nodeLabel()
        let comps = _componentsString()
        return "node[\(label)]\(comps)"
    }
    
    // Рекурсивный обход для печати дерева с «ветками»
    fileprivate func _graphLines(prefix: String, isLast: Bool, tokens: _TreeTokens) -> [String] {
        let label = _nodeLabel()
        let comps = _componentsString()
        
        // Текущая строка
        let connector = isLast ? tokens.lastBranch : tokens.branch
        var result: [String] = ["\(prefix)\(connector)node[\(label)]\(comps)"]
        
        // Префикс для детей (вертикальная «труба» или пустота)
        let childPrefix = prefix + (isLast ? tokens.space : tokens.vertical)
        
        // Дети
        for (idx, child) in children.enumerated() {
            let childIsLast = idx == children.count - 1
            result.append(contentsOf: child._graphLines(prefix: childPrefix, isLast: childIsLast, tokens: tokens))
        }
        return result
    }
    
    // Служебные: метка узла и строка компонентов
    fileprivate func _nodeLabel() -> String {
        if let name = debugName, !name.isEmpty {
            return name
        } else {
            return String(id.uuidString.prefix(8))
        }
    }
    
    fileprivate func _componentsString() -> String {
        let componentTypeNames = components.map { String(describing: type(of: $0)) }
        return componentTypeNames.isEmpty ? "" : " (\(componentTypeNames.joined(separator: ", ")))"
    }
}
