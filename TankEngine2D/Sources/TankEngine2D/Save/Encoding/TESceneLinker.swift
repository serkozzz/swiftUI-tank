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
    let sceneNode: TESceneNode2D
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
                    guard let data = ref.propertyValue.data(using: .utf8) else {
                        TELogger2D.error("restorePreviewableProperties. Could not convert JSON string to Data for : \(ref.propertyName)")
                        return
                    }
                    guard let decodedId = try? JSONDecoder().decode(UUID.self, from: data)
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
        
        
//        for viewWithUnresolvedRef in allViewsWithUnresolvedRefs {
//            TELogger2D.error("Linker could not resolve link. Is not allowed for view to have the refs to components")
//            return
//            for ref in viewWithUnresolvedRef.refs {
//                Mirror.propsForeach(viewWithUnresolvedRef.view) { child in
//                    
//                    guard child.label == ref.propertyName else { return }
//                    guard let decodedId = try? JSONDecoder().decode(UUID.self, from: ref.propertyValue)
//                        else {
//                        TELogger2D.error("Linker could not resolve link. UUID decoding error. \(String(describing: type(of: viewWithUnresolvedRef.view) )).\(ref.propertyName)")
//                            return
//                        }
//                    guard let component = componentsCache[decodedId] else  {
//                        TELogger2D.error("Linker could not resolve link. Refered Component is abscent in scene")
//                        return
//                    }
//                    updateView(node: viewWithUnresolvedRef.sceneNode, id: viewWithUnresolvedRef.view.id) { viewToUpdate in
//                        SafeKVC.setValue(component, forKey: ref.propertyName, of: viewToUpdate)
//                    }
//                    
//                    
//                }
//          }
//        }
    }
    
    func updateView(node: TESceneNode2D, id: UUID, update: (inout any TEView2D) -> Void) {
        guard let index = node.views.firstIndex(where: { $0.id == id }) else { return }
        update(&node.views[index])
    }
}


extension CodingUserInfoKey {
    static let sceneAssembler = CodingUserInfoKey(rawValue: "sceneAssembler")!
}
