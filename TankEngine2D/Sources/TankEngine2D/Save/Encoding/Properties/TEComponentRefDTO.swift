//
//  TEComponentCodableProperty.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 03.11.2025.
//

import Foundation


//is used only for ref to other components coding/encoding
struct TEComponentRefDTO: Codable {
    var propertyName: String
    var propertyValue: String
}
