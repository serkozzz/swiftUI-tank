//
//  TEComponentCodableProperty.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 03.11.2025.
//

import Foundation

struct TEEncodedProperty: Codable {
    var propertyName: String
    var propertyValue: Data
    var propertyType: String
}
