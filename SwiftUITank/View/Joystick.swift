//
//  Joystick.swift
//  Simple3DEngine
//
//  Created by Sergey Kozlov on 12.09.2025.
//

import SwiftUI
import simd

struct JoystickState {
    let normalizedToFingerVector: SIMD2<Float>
    let magnitude: Float
}

enum JoystickID {
    case left
    case right
}

@MainActor
protocol JoystickDelegate: AnyObject {
    func joystickDidBegin(id: JoystickID)
    func joystickDidChange(id: JoystickID, to state: JoystickState)
    func joystickDidEnd(id: JoystickID)
    func joystickDidReceiveDoubleTap(id: JoystickID)
}

@MainActor
struct Joystick: View {
    
    let id: JoystickID
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
                        delegate?.joystickDidReceiveDoubleTap(id: id)
                    }
            )
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged() { value in
                        var location = value.location
                        location.y = size.height - location.y
                        
                        location.x -= size.width / 2
                        location.y -= size.height / 2
                        
                        if !isTouched {
                            isTouched = true
                            delegate?.joystickDidBegin(id: id)
                        }
                        let toFingerVector = SIMD2(Float(location.x), Float(location.y))
                        
                        var magnitude = simd_length(toFingerVector) / Float(size.height / 2)
                        if magnitude > 1 { magnitude = 1 }
                        let normalizedToFinger = simd_normalize(toFingerVector)
                        
                        let state = JoystickState(normalizedToFingerVector: normalizedToFinger,
                                                  magnitude: magnitude)
                        delegate?.joystickDidChange(id: id, to: state)
                    }
                    .onEnded() { _ in
                        isTouched = false
                        delegate?.joystickDidEnd(id: id)
                    }
            )
    }
}

#Preview {
    Joystick(id: .left, delegate: nil)
}
