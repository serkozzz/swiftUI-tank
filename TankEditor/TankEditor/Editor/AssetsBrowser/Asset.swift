//
//  File.swift
//  TankEditor
//
//  Created by Sergey Kozlov on 24.11.2025.
//

import Foundation

enum AssetType {
    case file
    case folder
}

struct Asset : Identifiable {
    var id = UUID()
    var name: String
    var type: AssetType
}
