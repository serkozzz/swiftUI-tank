//
//  TEComponentSerializer2D.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 04.11.2025.
//

import Foundation

@MainActor
class TENodeViewsCoder {
    
    func encodeViews(_ components: [any TEView2D]) -> [TEViewDTO] {
        return components.map { encodeView($0) }
    }
    
    private func encodeView(_ view: any TEView2D) -> TEViewDTO {
        
        let structName = TEViewsRegister2D.shared.getKeyFor(type(of: view))
        let refs = encodeRefs(view)
        return TEViewDTO(structName: structName,
                         refsToOtherComponents: refs,
                         viewModelRef: view.getViewModel()?.id,
                         id: view.id)
    }
    
    
    
    private func encodeRefs(_ view: any TEView2D) -> [TEComponentRefDTO] {
        let result = [TEComponentRefDTO]()

//         made up the mind that you can't store any link in TEView2D
//        Mirror.propsForeach(view) { child in
//            guard let encodedRef = TECoderHelper.tryEncodeRef(mirrorProp: child) else { return }
//                result.append( encodedRef )
//        }
//        
        return result
    }
}
