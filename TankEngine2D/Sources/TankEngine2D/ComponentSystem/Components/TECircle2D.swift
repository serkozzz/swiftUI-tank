//
//  TECollision2D.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 02.10.2025.
//

import SwiftUI
import Combine



public class TECircle2D: TEComponent2D {
    
    @Published var size: CGSize = CGSize(width: 100, height: 100)

    @Published var name: String = "circle name"
    @Published var radius: Float = 30

    
    var collider: TECollider2D?
    var camera: TECamera2D?
    
    public required init() {
        super.init()
    }
}


extension TECircle2D {
    public override func printSerializableProperties() {
        super.printSerializableProperties()
        print("serializable: radius=\(self.radius)")
    }

    public override func encodeSerializableProperties() -> [String: String] {
        var dict = super.encodeSerializableProperties()
        do {
            var data = try JSONEncoder().encode(self.name)
            if let size = String(data: data, encoding: .utf8) {
                dict["name"] = size
            }
            data = try JSONEncoder().encode(self.radius)
            if let myStr = String(data: data, encoding: .utf8) {
                dict["radius"] = myStr
            }
        } catch {
            print("[TESerializable][warning] failed to encode size: \(error)")
        }
        return dict
    }

    public override func decodeSerializableProperties(_ dict: [String: String]) {
        super.decodeSerializableProperties(dict)
        if let json = dict["name"] {
            setSerializableValue(for: "name", from: json)
        }
        if let json = dict["radius"] {
            setSerializableValue(for: "radius", from: json)
        }
    }
    
    public override func setSerializableValue(for propertyName: String, from jsonString: String) {
        super.setSerializableValue(for: propertyName, from: jsonString)
        if propertyName == "name", let data = jsonString.data(using: .utf8 ) {
            if let value = try? JSONDecoder().decode(String.self, from: data) {
                self.name = value
            }
        }
        if propertyName == "radius", let data = jsonString.data(using: .utf8 ) {
            if let value = try? JSONDecoder().decode(Float.self, from: data) {
                self.radius = value
            }
        }
    }

}
