//
//  File.swift
//  TankEditor
//
//  Created by Sergey Kozlov on 24.11.2025.
//

import SwiftUI
import UniformTypeIdentifiers

enum AssetType : Codable {
    case file
    case folder
    case goUpFolder
}

struct Asset: Identifiable, Codable, Transferable {
    var id = UUID()
    var name: String
    var type: AssetType
    
    static var GO_UP_FOLDER: Asset = .init(name: "..", type: .goUpFolder)
    

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(contentType: .data) { asset in
            try JSONEncoder().encode(asset)
        } importing: { data in
            try JSONDecoder().decode(Asset.self, from: data)
        }
    }
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
