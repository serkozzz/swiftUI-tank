//
//  PropView.swift
//  TankEditor
//
//  Created by Sergey Kozlov on 04.12.2025.
//

import SwiftUI
import TankEngine2D


struct PropView: View {
    
    var component: TEComponent2D
    var propName: String
    var codedValue: String
    
    var body: some View {
        let type = Mirror.getPropType(component, propName: propName)
        if type != nil {
            Text(propName).propCell(alignment: .leading)
            if type! is Bool.Type {
                
                BoolRepresentaton(value: Binding(get: {
                    let data = codedValue.data(using: .utf8)!
                    return try! JSONDecoder().decode(Bool.self, from: data)
                }, set: { newValue in
                    let data = try! JSONEncoder().encode(newValue)
                    let jsonStr = String(data: data, encoding: .utf8)!
                    component.setSerializableValue(for: propName, from: jsonStr)
                }))
                .propCell(alignment: .trailing)
            } else if type! is String.Type {
                Text(codedValue).propCell(alignment: .trailing)
            } else if type! is Int.Type {
                Text(codedValue).propCell(alignment: .trailing)
            }
            else {
                Text(codedValue).propCell(alignment: .trailing)
            }
        }
        else {
            //TODO log error
        }
    }
}
