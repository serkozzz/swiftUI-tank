//
//  File.swift
//  TankEditor
//
//  Created by Sergey Kozlov on 24.11.2025.
//

enum AssetType {
    case file
    case folder
}

struct Asset {
    var name: String
    var type: AssetType
}
