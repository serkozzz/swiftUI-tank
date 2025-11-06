//
//  TEComponentSerializer2D.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 04.11.2025.
//

import Foundation

@MainActor
class TEViewsSerializer2D {
    
    func encodeViews(_ components: [any TEView2D]) -> [TEEncodedView2D] {
        return components.map { encodeView($0)}
    }
    
    func restoreViews(_ encodedViews: [TEEncodedView2D], scene: TEScene2D, linker: TEComponentsLinker2D) -> [any TEView2D] {
        let viewsWithRefs = encodedViews.map { restoreView(from: $0, scene: scene, linker: linker) }
    
        linker.addRefs(viewsWithRefs.compactMap{$0}.filter{ !$0.refs.isEmpty })
        return viewsWithRefs.map{ $0 == nil ? TEMissedView2D(viewModel: nil) : $0!.view}

    }
    
    private func encodeView(_ view: any TEView2D) -> TEEncodedView2D {
        let structName = String(reflecting: type(of: view))
        let properties = encodePreviewable(view)
        let refs = encodeRefs(view)
        return TEEncodedView2D(structName: structName, properties: properties, refsToOtherComponents: refs, viewModelRef: view.getViewModel()?.id)
    }
    
    private func restoreView(from encodedView: TEEncodedView2D, scene: TEScene2D, linker: TEComponentsLinker2D) -> TEViewWithUnresolvedRefs2D? {
        
        let type = TEViewsRegister2D.shared.registredViews[encodedView.structName]
        guard let type else {
            TELogger2D.print("Couldn't restore view. View with type \(encodedView.structName) not registered")
            return nil
        }
        
        var vm: TEComponent2D? = nil
        if let viewModelRef = encodedView.viewModelRef {
            vm = linker.getComponentBy(id: viewModelRef, scene: scene)
        }
        var view = type.init(viewModel: vm)
        
        view = restorePreviewableProperties(for: view, from: encodedView)
        return TEViewWithUnresolvedRefs2D(view: view,
                                          refs: encodedView.refsToOtherComponents)
    }
    
    
    private func encodePreviewable(_ view: any TEView2D) -> [TEEncodedProperty] {
        var result = [TEEncodedProperty]()
    
        Mirror.propsForeach(view) { child in
                guard let previewable = child.value as? TEPreviewable2DProtocol else { return }
                guard let propertyName = child.label else { return }
                
                
                let valueData = try! JSONEncoder().encode(previewable.value)
                result.append( TEEncodedProperty(propertyName: propertyName,
                                                            propertyValue: valueData,
                                                            propertyType: String(reflecting: previewable.valueType) ))
        }
        
        return result
    }
    
    private func encodeRefs(_ view: any TEView2D) -> [TEEncodedProperty] {
        var result = [TEEncodedProperty]()

        Mirror.propsForeach(view) { child in
                
                guard let componentRef = child.value as? TEComponent2D else { return }
                guard let propertyName = child.label else { return }
                
                
                let valueData = try! JSONEncoder().encode(componentRef.id)
                result.append( TEEncodedProperty(propertyName: propertyName,
                                                            propertyValue: valueData,
                                                            propertyType: String(reflecting: UUID.self) ))
        }
        
        return result
    }
    
    private func restorePreviewableProperties(for view: any TEView2D, from encodedView:TEEncodedView2D) -> any TEView2D {
        
        Mirror.propsForeach(view) { child in
            
                guard let previewable = child.value as? TEPreviewable2DProtocol else { return }
                guard let property = encodedView.properties.first(where: { $0.propertyName == child.label}) else { return }
                
                let innerType = previewable.self.valueType
                guard let decodedValue = try? JSONDecoder().decode(innerType, from: property.propertyValue)
                else {
                    TELogger2D.print("Could not restore innerValue for Previewable<> property: \(property.propertyName) of type: \(String(describing: previewable.valueType))")
                    return
                }
                
                // Устанавливаем значение внутрь обёртки
                if !previewable.setValue(decodedValue) {
                    TELogger2D.print("Type mismatch when assigning decoded value to Previewable<> property: \(property.propertyName)")
                }

        }
    }
}

