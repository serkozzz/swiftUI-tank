//
//  TEComponent2DJSONRepresentation.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 03.11.2025.
//

import Foundation
import SafeKVC

@MainActor
struct TEEncodedComponent2D: @MainActor Codable {
    var className: String
    var properties: [TEEncodedProperty]
    var refsToOtherComponents: [TEEncodedProperty]
    var componentID: UUID
}



