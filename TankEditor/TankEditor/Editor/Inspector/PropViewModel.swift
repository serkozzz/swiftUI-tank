//
//  PropViewModel.swift
//  TankEditor
//
//  Created by Sergey Kozlov on 05.12.2025.
//

import SwiftUI
import TankEngine2D
import Combine



class PropViewModel: ObservableObject {
    
    enum PropType {
        case bool
        case number
        case string
        case other
    }
    
    private(set) var propName: String
    private(set) var propType: PropType
    var codedValue: String
    
    @ObservedObject var component: TEComponent2D
    private var componentCopyForMirror: TEComponent2D //@ObservedObject is wrapper that don't allow you get TEComponent props directlry
    
    init(component: TEComponent2D, propName: String, codedValue: String) {
        self.component = component
        self.componentCopyForMirror = component
        self.propName = propName
        self.codedValue = codedValue
        
        self.propType = .other
        self.propType = detectPropType()
    }
    
    
    var propBinding: Binding<Bool> {
        Binding(get: { [unowned self] in
            let data = codedValue.data(using: .utf8)!
            return try! JSONDecoder().decode(Bool.self, from: data)
        }, set: { [unowned self]  newValue in
            let data = try! JSONEncoder().encode(newValue)
            let jsonStr = String(data: data, encoding: .utf8)!
            component.setSerializableValue(for: propName, from: jsonStr)
            
            
            let dataNew = codedValue.data(using: .utf8)!
            let newValue = try! JSONDecoder().decode(Bool.self, from: dataNew)
        })
    }
    
    private func detectPropType() -> PropType {
        
        let type = Mirror.getPropType(componentCopyForMirror, propName: propName)
        if type != nil {
            if type! is Bool.Type {
                return .bool
            }
            else if type! is String.Type {
                return .string
            }
            else if type! is Int.Type {
                return .number
            }
            else {
                return .other
            }
        }
        return .other
    }
    
}
