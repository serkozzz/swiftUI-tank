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
        case integer
        case float
        case string
        case vector2
        case vector3
        case other
    }
    
    private(set) var propName: String
    private(set) var propType: PropType
    var codedValue: String {
        let dict = component.encodeSerializableProperties()
        return dict[propName]!
    }
    
    @ObservedObject var component: TEComponent2D
    private var componentCopyForMirror: TEComponent2D //@ObservedObject is wrapper that don't allow you get TEComponent props directlry
    private var cancellable: AnyCancellable?
    
    init(component: TEComponent2D, propName: String) {
        self.component = component
        self.componentCopyForMirror = component
        self.propName = propName
        
        self.propType = .other
        self.propType = detectPropType()
        
        cancellable = self.component.objectWillChange.sink(receiveValue: { self.objectWillChange.send() })
    }
    
    
    func propBinding<T: Codable>() -> Binding<T> {
        Binding(get: { [unowned self] in
            let data = codedValue.data(using: .utf8)!
            return try! JSONDecoder().decode(T.self, from: data)
        }, set: { [unowned self]  newValue in
            let data = try! JSONEncoder().encode(newValue)
            let jsonStr = String(data: data, encoding: .utf8)!
            component.setSerializableValue(for: propName, from: jsonStr)
            
            let props = component.encodeSerializableProperties()
            print("Hello: \(props)")
        })
    }
    
    func stringPropBinding() -> Binding<String> {
        Binding(
            get: { [unowned self] in
                codedValue.unquoted()
            },
            set: { [unowned self] newValue in
                let json = newValue.quotedJSON()
                component.setSerializableValue(for: propName, from: json)
            }
        )
    }

    
    private func detectPropType() -> PropType {
        
        let type = Mirror.getPropType(componentCopyForMirror, propName: propName)
        if let type {
            if type is Bool.Type {
                return .bool
            }
            else if type is String.Type {
                return .string
            }
            else if type is Int.Type {
                return .integer
            }
            else if type is Float.Type || type is Double.Type {
                return .float
            }
            else if type is SIMD2<Float>.Type  {
                return .vector2
            }
            else if type is SIMD3<Float>.Type  {
                return .vector3
            }
            else {
                return .other
            }
        }
        return .other
    }
    
}
