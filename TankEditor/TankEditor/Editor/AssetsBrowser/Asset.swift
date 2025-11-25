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
    case goUpFolder
}

struct Asset: Identifiable {
    var id = UUID()
    var name: String
    var type: AssetType
    
    static var GO_UP_FOLDER: Asset = .init(name: "..", type: .goUpFolder)
}

extension Asset {
    var displayName: String {
        switch type {
        case .folder:
            return name
        case .file:
            return (name as NSString).deletingPathExtension
        case .goUpFolder:
            return name
        }
    }
}
