//
//  SceneSerializer.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 27.10.2025.
//

import SwiftUI

@MainActor
class SceneSerializer {
        private let encoder = JSONEncoder()
        private let decoder = JSONDecoder()
    
    
        
//        func encode(_ scene: TEScene2D) throws -> Data {
//            let root = scene.rootNode
//            let dict = try encodeNode(root)
//            return try JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted])
//        }
//        
//        private func encodeNode(_ node: TESceneNode2D) throws -> [String: Any] {
//            let childrenCopy = node.children
//            node.children = []
//            
//            let bodyData: Data
//            bodyData = try encoder.encode(node)
//            
//            guard var dict = try JSONSerialization.jsonObject(with: bodyData) as? [String: Any] else {
//                throw NSError(domain: "EncoderError", code: 1)
//            }
//            dict["kind"] = nodeKind(node).rawValue
//            node.children = childrenCopy
//            
//            if !node.children.isEmpty {
//                dict["children"] = try node.children.map { try encodeNode($0) }
//            }
//            
//            if !JSONSerialization.isValidJSONObject(dict) {
//                print("❌ Invalid JSON object:", dict)
//                throw NSError(domain: "JSONSerialization", code: 0, userInfo: nil)
//            }
//            return dict
//        }
//        
//        func decodeTree(data: Data) throws -> Node {
//            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
//            guard let dict = jsonObject as? [String: Any] else {
//                throw NSError(domain: "JSONSerialization", code: 1, userInfo: [NSLocalizedDescriptionKey: "Root JSON is not a dictionary"])
//            }
//            return try decodeNode(dict: dict)
//        }
//        
//        func decodeNode(dict: [String: Any]) throws -> Node {
//            // 1) kind
//            guard let kindRaw = dict["kind"] as? String, let kind = NodeKind(rawValue: kindRaw) else {
//                throw NSError(domain: "DecoderError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Missing or invalid 'kind' field"])
//            }
//            
//            // 2) prepare body by removing service fields (kind, children)
//            var bodyDict = dict
//            bodyDict.removeValue(forKey: "kind")
//            let childrenArray = dict["children"] as? [[String: Any]] ?? []
//            bodyDict["children"] = []
//            
//            // 3) convert body to Data
//            let bodyData = try JSONSerialization.data(withJSONObject: bodyDict, options: [])
//            
//            // 4) decode specific node type
//            let node: Node
//            switch kind {
//            case .base:
//                node = try decoder.decode(Node.self, from: bodyData)
//            case .variable:
//                node = try decoder.decode(VariableNode.self, from: bodyData)
//            case .view:
//                node = try decoder.decode(ViewNode.self, from: bodyData)
//            }
//            
//            // 5) decode children recursively
//            if !childrenArray.isEmpty {
//                node.children = try childrenArray.map { try decodeNode(dict: $0) }
//            } else {
//                node.children = []
//            }
//            
//            return node
//        }
//        
//        func nodeKind(_ node: Node) -> NodeKind {
//            if (node is ViewNode) { return .view }
//            if (node is VariableNode) { return .variable }
//            return .base
//        }
//    }
}

