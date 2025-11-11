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
            guard let previewable = child.value as? (any TEPreviewable2D) else { return }
            guard let propertyName = child.label else { return }
            
            // Ключ: оборачиваем конкретный Value в Encodable-бокс
            let valueData = try! JSONEncoder().encode(previewable)
            let valueJsonStr = String(data: valueData, encoding: .utf8)!
            result.append(TEPropertyDTO(propertyName: propertyName,
                                        propertyValue: valueJsonStr,
                                        propertyType: String(reflecting: previewable.valueType)))
        }
        
        return result
    }
    
    private func encodeRefs(_ view: any TEView2D) -> [TEPropertyDTO] {
        var result = [TEPropertyDTO]()
        
        Mirror.propsForeach(view) { child in
            guard let componentRef = child.value as? TEComponent2D else { return }
            guard let propertyName = child.label else { return }
            
            let valueData = try! JSONEncoder().encode(componentRef.id)
            let valueJsonStr = String(data: valueData, encoding: .utf8)!
            result.append(TEPropertyDTO(propertyName: propertyName,
                                        propertyValue: valueJsonStr,
                                        propertyType: String(reflecting: UUID.self)))
        }
        
        return result
    }
}
