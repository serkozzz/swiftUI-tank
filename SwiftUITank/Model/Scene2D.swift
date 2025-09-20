//
//  Scene.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 20.09.2025.
//

import SwiftUI

class Scene2D: ObservableObject {
    var camera = Camera()
    var player = PlayerTank()
    var enemies = [Enemy()]
}
