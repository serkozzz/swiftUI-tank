//
//  String.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 07.12.2025.
//

import Foundation

public extension String {
    
    func unquoted() -> String {
        if hasPrefix("\""), hasSuffix("\""), count >= 2 {
            return String(dropFirst().dropLast())
        }
        return self
    }
    
    func quotedJSON() -> String {
     
        let data = try! JSONEncoder().encode(self)
        return String(data: data, encoding: .utf8)!
    }
}
