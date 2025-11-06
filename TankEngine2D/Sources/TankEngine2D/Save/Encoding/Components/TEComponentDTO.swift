//
//  TEComponent2DJSONRepresentation.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 03.11.2025.
//

import Foundation
import SafeKVC

@MainActor
struct TEComponentDTO: @MainActor Codable {
    var className: String
    var properties: [TEPropertyDTO]
    var refsToOtherComponents: [TEPropertyDTO]
    var componentID: UUID
}



