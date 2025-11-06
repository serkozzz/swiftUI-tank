//
//  TEEncodedView2D.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 06.11.2025.
//

import Foundation

@MainActor
struct TEEncodedView2D: @MainActor Codable {
    var structName: String
    var properties: [TEEncodedProperty]
    var refsToOtherComponents: [TEEncodedProperty]
}
