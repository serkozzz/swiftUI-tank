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
    var refs: [TEPropertyDTO]
}

struct TEViewWithUnresolvedRefs2D {
    var view: any TEView2D
    var refs: [TEPropertyDTO]
}

@MainActor
class TESceneLinker {
    private var allComponentsWithUnresolvedRefs = [TEComponentWithUnresolvedRefs2D]()
    private var allViewsWithUnresolvedRefs = [TEViewWithUnresolvedRefs2D]()
    
    func addRefs(_ refs: [TEComponentWithUnresolvedRefs2D]) {
        self.allComponentsWithUnresolvedRefs.append(contentsOf: refs)
    }
    
    func addRefs(_ refs: [TEViewWithUnresolvedRefs2D]) {
        self.allViewsWithUnresolvedRefs.append(contentsOf: refs)
    }
    
    func resolveLinks(componentsCache: [UUID: TEComponent2D]) {
        for componentWithRef in allComponentsWithUnresolvedRefs {
            for ref in componentWithRef.refs {
                
                
                Mirror.propsForeach(componentWithRef.component) { child in
                    
                    guard child.label == ref.propertyName else { return }
                    guard let decodedId = try? JSONDecoder().decode(UUID.self, from: ref.propertyValue)
                        else {
                        TELogger2D.error("Linker could not resolve link. UUID decoding error. \(String(describing: type(of: componentWithRef.component) )).\(ref.propertyName)")
                            return
                        }
                    guard let component = componentsCache[decodedId] else  {
                        TELogger2D.error("Linker could not resolve link. Refered Component is abscent in scene")
                        return
                    }
                    SafeKVC.setValue(component, forKey: ref.propertyName, of: componentWithRef.component)
                    
                }
            }
        }
    }
    
    func getComponentBy(id: UUID, scene: TEScene2D) -> TEComponent2D? {
        let allComponents = scene.rootNode.getAllComponentsInSubtree(TEComponent2D.self)
        return allComponents.first(where: {$0.id == id })
        
    }
}


extension CodingUserInfoKey {
    static let sceneAssembler = CodingUserInfoKey(rawValue: "sceneAssembler")!
}
