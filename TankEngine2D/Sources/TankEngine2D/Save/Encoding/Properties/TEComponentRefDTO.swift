//
//  TEComponentCodableProperty.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 03.11.2025.
//

import Foundation


// is used only for ref to other components coding/encoding
public class TEComponentRefDTO: NSObject, Codable {
    public let propertyName: String
    public let uuidString: String

    public init(propertyName: String, uuidString: String) {
        self.propertyName = propertyName
        self.uuidString = uuidString
    }
}
