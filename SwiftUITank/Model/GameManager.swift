//
//  GameManager.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 05.10.2025.
//

import SwiftUI
import TankEngine2D

@MainActor
class GameManager : ObservableObject {
    @Published var levelManager: GameLevelManager?
    
    init() {
    }
}
