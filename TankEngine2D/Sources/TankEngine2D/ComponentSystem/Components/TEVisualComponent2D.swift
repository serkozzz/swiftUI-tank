//
//  TEVisualComponent2D.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 18.12.2025.
//
import SwiftUI

//open class TEVisualComponent2D: TEComponent2D {
//    
//    @available(*, unavailable, message: "You must override makeView() in subclasses")
//    open func makeView() -> AnyView {
//        fatalError()
//    }
//}

import SwiftUI

@MainActor
public protocol TEVisualComponent2D: @MainActor Identifiable, AnyObject {
    func createView() -> AnyView
    var boundingBox: CGSize { get }

}

