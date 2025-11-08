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
        return components.map { encodeView($0)}
    }
    
    private func encodeView(_ view: any TEView2D) -> TEViewDTO {
        let structName = String(reflecting: type(of: view))
        let properties = encodePreviewable(view)
        let refs = encodeRefs(view)
        return TEViewDTO(structName: structName, properties: properties, refsToOtherComponents: refs, viewModelRef: view.getViewModel()?.id, id: view.id)
    }
    
    
    
    private func encodePreviewable(_ view: any TEView2D) -> [TEPropertyDTO] {
        var result = [TEPropertyDTO]()
    
        Mirror.propsForeach(view) { child in
                guard let previewable = child.value as? TEPreviewable2DProtocol else { return }
                guard let propertyName = child.label else { return }
                
                
                let valueData = try! JSONEncoder().encode(previewable.value)
                result.append( TEPropertyDTO(propertyName: propertyName,
                                                            propertyValue: valueData,
                                                            propertyType: String(reflecting: previewable.valueType) ))
        }
        
        return result
    }
    
    private func encodeRefs(_ view: any TEView2D) -> [TEPropertyDTO] {
        var result = [TEPropertyDTO]()

        Mirror.propsForeach(view) { child in
                
                guard let componentRef = child.value as? TEComponent2D else { return }
                guard let propertyName = child.label else { return }
                
                
                let valueData = try! JSONEncoder().encode(componentRef.id)
                result.append( TEPropertyDTO(propertyName: propertyName,
                                                            propertyValue: valueData,
                                                            propertyType: String(reflecting: UUID.self) ))
        }
        
        return result
    }
   
}

