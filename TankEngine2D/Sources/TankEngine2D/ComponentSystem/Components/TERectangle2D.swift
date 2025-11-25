//
//  TECollision2D.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 02.10.2025.
//

import Foundation



public class TERectangle2D: TEComponent2D {
    
    @TEPreviewable var size: CGSize = CGSize(width: 100, height: 100)
    
    public required init() {
        super.init()
    }
}


extension TERectangle2D {
    public override func printSerializableProperties() {
        super.printSerializableProperties()
        print("serializable: size=\(self.size)")
    }

    public override func encodeSerializableProperties() -> [String: String] {
        var dict = super.encodeSerializableProperties()
        do {
            let data = try JSONEncoder().encode(self.size)
            if let str = String(data: data, encoding: .utf8) {
                dict["size"] = str
            }
        } catch {
            print("[TESerializable][warning] failed to encode size: \(error)")
        }
        return dict
    }

    public override func decodeSerializableProperties(_ dict: [String: String]) {
        super.decodeSerializableProperties(dict)
        if let json = dict["size"], let data = json.data(using: .utf8) {
            if let value = try? JSONDecoder().decode(CGSize.self, from: data) {
                self.size = value
            }
        }
    }
}
