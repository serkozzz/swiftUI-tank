//
//  Canon.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 25.09.2025.
//

import SwiftUI
import Combine

class Cannon : BaseSceneObject {
    @Published var barrelAngleRadians: Double = 0

    
    private var cancelables: Set<AnyCancellable> = []
    
    init() {
        super.init()
        Timer.publish(every: 1, on: .main, in: .common)
             .autoconnect()
             .sink { [unowned self] _ in
                 self.destroyed.toggle()
             }.store(in: &cancelables)

    }
    
    override func update(timeFromLastUpdate: TimeInterval) {
        barrelAngleRadians += timeFromLastUpdate * 0.01
        barrelAngleRadians.formTruncatingRemainder(dividingBy: 2 * .pi)
        
    }
    

}
