//
//  TECollision2D.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 02.10.2025.
//

import SwiftUI

public enum TECollider2DShape : Equatable, Codable {
    case geometry
    case customBoundingBox(CGSize)
}


public class TECollider2D: TEComponent2D {
    
    private(set) var shape: TECollider2DShape
    
    public required init() {
        shape = .geometry
        super.init()
    }


}

extension TECollider2D: @MainActor TEVisualComponent2D {
    public func createView() -> AnyView {
        AnyView(TEColliderView2D(viewModel: self))
    }
    
    public var boundingBox: CGSize {
        switch shape {
        case .geometry:
            let visualComp = self.owner?.visualComponents.first
            TEAssert.precondition(visualComp != nil, "Geometry object is not set for the collider with shape.geometry")
            return visualComp!.boundingBox
        case .customBoundingBox(let bb):
            return bb
        }
    }
    
}


extension TECollider2D {
    public override func printSerializableProperties() {
        super.printSerializableProperties()
        print("serializable: shape=\(self.shape)")
    }

    public override func encodeSerializableProperties() -> [String: String] {
        var dict = super.encodeSerializableProperties()
        do {
            let data = try JSONEncoder().encode(self.shape)
            if let str = String(data: data, encoding: .utf8) {
                dict["shape"] = str
            }
        } catch {
            print("[TESerializable][warning] failed to encode '\("shape")': \(error)")
        }
        return dict
    }

    public override func decodeSerializableProperties(_ dict: [String: String]) {
        super.decodeSerializableProperties(dict)
        if let json = dict["shape"], let data = json.data(using: .utf8) {
            if let value = try? JSONDecoder().decode(TECollider2DShape.self, from: data) {
                self.shape = value
            }
        }
    }
    
    public override func setSerializableValue(for propertyName: String, from jsonString: String) {
        
    }

}
