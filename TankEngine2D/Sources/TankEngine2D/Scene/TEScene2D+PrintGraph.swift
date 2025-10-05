//
//  Scene2D+PrintGraph.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 05.10.2025.
//

import Foundation

@MainActor
public extension TEScene2D {
    

    func printGraph() {
        print(graphDescription())
    }
    
    
    func graphDescription() -> String {
        var lines: [String] = ["root"]
        for child in rootNode.children {
            lines.append(contentsOf: child._graphLines(level: 1))
        }
        return lines.joined(separator: "\n")
    }
}

@MainActor
extension TESceneNode2D {
    // Вспомогательный рекурсивный обход для печати.
    fileprivate func _graphLines(level: Int) -> [String] {
        let indent = String(repeating: "    ", count: level)
        
        let componentTypeNames = components.map { String(describing: type(of: $0)) }
        let comps = componentTypeNames.isEmpty ? "" : "(\(componentTypeNames.joined(separator: ", ")))"
        
        var result: [String] = ["\(indent)-node\(comps)"]
        for child in children {
            result.append(contentsOf: child._graphLines(level: level + 1))
        }
        return result
    }
}
