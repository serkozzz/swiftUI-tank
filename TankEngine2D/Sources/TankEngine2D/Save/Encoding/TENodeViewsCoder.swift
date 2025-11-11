//
//  TEComponentSerializer2D.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 04.11.2025.
//

import Foundation

@MainActor
class TENodeViewsCoder {
    
    // Бокс фиксирует конкретный T: Encodable, избегая existential any Codable
    private struct _AnyEncodableBox<T: Encodable>: Encodable {
        let base: T
        func encode(to encoder: Encoder) throws {
            try base.encode(to: encoder)
        }
    }
    
    func encodeViews(_ components: [any TEView2D]) -> [TEViewDTO] {
        return components.map { encodeView($0) }
    }
    
    private func encodeView(_ view: any TEView2D) -> TEViewDTO {
        let structName = String(reflecting: type(of: view))
        let properties = encodePreviewable(view)
        let refs = encodeRefs(view)
        return TEViewDTO(structName: structName,
                         properties: properties,
                         refsToOtherComponents: refs,
                         viewModelRef: view.getViewModel()?.id,
                         id: view.id)
    }
    
    private func encodePreviewable(_ view: any TEView2D) -> [TEPropertyDTO] {
        var result = [TEPropertyDTO]()
        
        Mirror.propsForeach(view) { child in
            guard let encodedProp = TECoderHelper.tryEncodePreviewable(mirrorProp: child) else { return }
            result.append(encodedProp)
        }
        
        return result
    }
    
    private func encodeRefs(_ view: any TEView2D) -> [TEPropertyDTO] {
        var result = [TEPropertyDTO]()
        
        Mirror.propsForeach(view) { child in
            guard let encodedRef = TECoderHelper.tryEncodeRef(mirrorProp: child) else { return }
                result.append( encodedRef )
        }
        
        return result
    }
}
