//
//  TEEncodedView2D.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 06.11.2025.
//

import Foundation

@MainActor
struct TEViewDTO: @MainActor Codable {
    var structName: String
    var properties: [TEPropertyDTO]
    var refsToOtherComponents: [TEPropertyDTO]
    var viewModelRef: UUID?
}
