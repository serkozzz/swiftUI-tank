//
//  TECollision2D.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 02.10.2025.
//

import Foundation



public class TERectangle2D: TEComponent2D {
    
    var size: CGSize = CGSize(width: 100, height: 100)
    var myStr: String = "string type"
    var myNumber: Float = 30
    var myBool: Bool = true
    
    var collider: TECollider2D?
    var camera: TEComponent2D?
    
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
            var data = try JSONEncoder().encode(self.size)
            if let size = String(data: data, encoding: .utf8) {
                dict["size"] = size
            }
            data = try JSONEncoder().encode(self.myStr)
            if let myStr = String(data: data, encoding: .utf8) {
                dict["myStr"] = myStr
            }
            data = try JSONEncoder().encode(self.myNumber)
            if let myNumber = String(data: data, encoding: .utf8) {
                dict["myNumber"] = myNumber
            }
            data = try JSONEncoder().encode(self.myBool)
            if let myBool = String(data: data, encoding: .utf8) {
                dict["myBool"] = myBool
            }
        } catch {
            print("[TESerializable][warning] failed to encode size: \(error)")
        }
        return dict
    }

    public override func decodeSerializableProperties(_ dict: [String: String]) {
        super.decodeSerializableProperties(dict)
        if let json = dict["size"] {
            setSerializableValue(for: "size", from: json)
        }
        if let json = dict["myStr"] {
            setSerializableValue(for: "myStr", from: json)
        }
        if let json = dict["myNumber"] {
            setSerializableValue(for: "myNumber", from: json)
        }
        if let json = dict["myBool"] {
            setSerializableValue(for: "myBool", from: json)
        }
    }
    
    public override func setSerializableValue(for propertyName: String, from jsonString: String) {
        super.setSerializableValue(for: propertyName, from: jsonString)
        if propertyName == "size", let data = jsonString.data(using: .utf8 ) {
            if let value = try? JSONDecoder().decode(CGSize.self, from: data) {
                self.size = value
            }
        }
        if propertyName == "myStr", let data = jsonString.data(using: .utf8 ) {
            if let value = try? JSONDecoder().decode(String.self, from: data) {
                self.myStr = value
            }
        }
        if propertyName == "myNumber", let data = jsonString.data(using: .utf8 ) {
            if let value = try? JSONDecoder().decode(Float.self, from: data) {
                self.myNumber = value
            }
        }
        if propertyName == "myBool", let data = jsonString.data(using: .utf8 ) {
            if let value = try? JSONDecoder().decode(Bool.self, from: data) {
                self.myBool = value
            }
        }
    }

}
