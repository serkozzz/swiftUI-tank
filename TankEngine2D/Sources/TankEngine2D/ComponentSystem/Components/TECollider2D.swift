//
//  TECollision2D.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 02.10.2025.
//

import Foundation

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

    public var boundingBox: CGSize {
        switch shape {
        case .geometry:
            let view = self.owner?.view
            TEAssert.precondition(view != nil, "Geometry object is not set for the collider with shape.geometry")
            return view!.boundingBox
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
