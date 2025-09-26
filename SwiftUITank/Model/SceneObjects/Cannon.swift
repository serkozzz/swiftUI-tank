//
//  Canon.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 25.09.2025.
//

import SwiftUI
import Combine

class Cannon : BaseSceneObject {
    @Published var barrelAngle: Double = 0
    @Published var destroyed: Bool = false
    
    private var cancelables: Set<AnyCancellable> = []
    
    init() {
        super.init()
        Timer.publish(every: 1, on: .main, in: .common)
             .autoconnect()
             .sink { [unowned self] _ in
                 self.destroyed.toggle()
             }.store(in: &cancelables)

    }
    

}
