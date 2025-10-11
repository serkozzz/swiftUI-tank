//
//  TestRotator.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 12.10.2025.
//

import SwiftUI

struct RadarView: View {
    @ObservedObject var model: Radar
    var body: some View {
        Rectangle().stroke(model.color)
        
    }
}

#Preview {
    RadarView(model: Radar(color: .blue))
}
