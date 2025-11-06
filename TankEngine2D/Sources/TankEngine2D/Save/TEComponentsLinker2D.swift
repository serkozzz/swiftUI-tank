//
//  TEComponentsLinker.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 05.11.2025.
//

import Foundation
import SafeKVC

struct TEComponentWithUnresolvedRefs2D {
    var component: TEComponent2D
    var refs: [TEEncodedProperty]
}

@MainActor
class TEComponentsLinker2D {
    private var allComponentsWithUnresolvedRefs = [TEComponentWithUnresolvedRefs2D]()
    
    func addRefs(_ refs: [TEComponentWithUnresolvedRefs2D]) {
        self.allComponentsWithUnresolvedRefs.append(contentsOf: refs)
    }
    
    func resolveLinks(scene: TEScene2D) {
        let allComponents = scene.rootNode.getAllComponentsInSubtree(TEComponent2D.self)
        for componentWithRef in allComponentsWithUnresolvedRefs {
            for ref in componentWithRef.refs {
                
                
                Mirror.propsForeach(componentWithRef.component) { child in
                    
                    guard child.label == ref.propertyName else { return }
                    guard let decodedId = try? JSONDecoder().decode(UUID.self, from: ref.propertyValue)
                        else {
                        TELogger2D.print("Linker could not resolve link. UUID decoding error. \(String(describing: type(of: componentWithRef.component) )).\(ref.propertyName)")
                            return
                        }
                    let component = allComponents.first(where: {$0.id == decodedId})
                    SafeKVC.setValue(component, forKey: ref.propertyName, of: componentWithRef.component)
                }
            }
        }
    }
}


extension CodingUserInfoKey {
    static let componentsLinker2D = CodingUserInfoKey(rawValue: "componentsLinker2D")!
}
