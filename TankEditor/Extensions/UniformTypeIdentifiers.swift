//
//  UITypeIdentifier.swift
//  TankEditor
//
//  Created by Sergey Kozlov on 09.12.2025.
//

import UniformTypeIdentifiers

extension UTType {
    static let viewDrag = UTType(exportedAs: "com.myapp.view-drag")
    static let componentDrag = UTType(exportedAs: "com.myapp.component-drag")
    static let nodeRefDrag = UTType(exportedAs: "com.myapp.node-ref-drag")
}
