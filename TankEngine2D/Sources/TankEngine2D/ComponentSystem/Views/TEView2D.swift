//
//  TEView2D.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 05.11.2025.
//

import SwiftUI

public protocol TEView2D: View {
    var boundingBox: CGSize { get }
    init (viewModel: TEComponent2D?) 
    func getViewModel() -> TEComponent2D
}
