//
//  Joystick.swift
//  Simple3DEngine
//
//  Created by Sergey Kozlov on 12.09.2025.
//

import SwiftUI
import simd

struct JoystickState {
    enum rotationSign: Int {
        case clockwise = 1
        case counterClockwise = -1
    }
    let movementDirection: SIMD2<Float>?
    let movementIntencity: Float?  //[0,1]
    let rotationIntencity: Float?  //[0,1]
    let rotationSign: rotationSign?
}

@MainActor
protocol JoystickDelegate: AnyObject {
    func dragBegan() -> Void
    func dragChanged(state: JoystickState) -> Void
    func dragEnded() -> Void
    func doubleTapped() -> Void
}

@MainActor
struct Joystick: View {
    
    weak var delegate: JoystickDelegate?
    @State private var isTouched = false
    @State private var size: CGSize = .zero

    var body: some View {
        Circle()
            .stroke(Color.blue, lineWidth: 3)
            .contentShape(Circle())
            .onGeometryChange(for: CGSize.self, of: { $0.size }) { newSize in
                size = newSize
            }
            .highPriorityGesture(
                TapGesture(count: 2)
                    .onEnded {
                        delegate?.doubleTapped()
                    }
            )
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged() { value in
                        var location = value.location
                        location.y = size.height - location.y
                        
                        location.x -= size.width / 2
                        location.y -= size.height / 2
                        
                        print(value)
                        if(!isTouched) {
                            isTouched = true
                            delegate?.dragBegan()
                        }
                        let toFingerVector = SIMD2(Float(location.x), Float(location.y))
                        
                        var intensity = simd_length(toFingerVector) / Float(size.height / 2)
                        if intensity > 1 { intensity = 1 }
                        let normalizedDirection = simd_normalize(toFingerVector)
                        
                        let state = JoystickState(movementDirection: normalizedDirection,
                                                  movementIntencity: intensity,
                                                  rotationIntencity: nil,
                                                  rotationSign: nil)
                        delegate?.dragChanged(state: state )
                    }
                    .onEnded() {_ in
                        isTouched = false
                        delegate?.dragEnded()
                    }
                )
    }
}


#Preview {

    Joystick(delegate: nil)
}
