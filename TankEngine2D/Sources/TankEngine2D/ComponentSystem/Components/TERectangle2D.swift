//
//  TECollision2D.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 02.10.2025.
//

import SwiftUI
import Combine



public class TERectangle2D: TEComponent2D {
    
    @Published var size: CGSize = CGSize(width: 100, height: 100)
    @Published var myStr: String = "string type"
    @Published var myNumber: Float = 30
    @Published var myBool: Bool = true
    @Published var myVector2: SIMD2<Float> = .one
    @Published var myVector3: SIMD3<Float> = .one
    
    var collider: TECollider2D?
    @Published var camera: TECamera2D?
    
    public required init() {
        super.init()
    }
}

extension TERectangle2D: @MainActor TEVisualComponent2D {
    public func createView() -> AnyView {
        AnyView(TERectangleView2D(viewModel: self))
    }
    
    public var boundingBox: CGSize {
        size
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
            data = try JSONEncoder().encode(self.myVector2)
            if let myNumber = String(data: data, encoding: .utf8) {
                dict["myVector2"] = myNumber
            }
            data = try JSONEncoder().encode(self.myVector3)
            if let myBool = String(data: data, encoding: .utf8) {
                dict["myVector3"] = myBool
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
        if let json = dict["myVector2"] {
            setSerializableValue(for: "myVector2", from: json)
        }
        if let json = dict["myVector3"] {
            setSerializableValue(for: "myVector3", from: json)
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
        if propertyName == "myVector2", let data = jsonString.data(using: .utf8 ) {
            if let value = try? JSONDecoder().decode(SIMD2<Float>.self, from: data) {
                self.myVector2 = value
            }
        }
        if propertyName == "myVector3", let data = jsonString.data(using: .utf8 ) {
            if let value = try? JSONDecoder().decode(SIMD3<Float>.self, from: data) {
                self.myVector3 = value
            }
        }
    }

}
