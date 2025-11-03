//
//  TEComponent2DJSONRepresentation.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 03.11.2025.
//

import Foundation

@MainActor
class TEComponent2DJSONRepresentation: @MainActor Codable {
    var className: String
    var propertiesStr: String
    
    init(_ component: TEComponent2D) throws {
        self.className = String(reflecting: type(of: component))
        let propsDict = component.encodedData()
       
        let data = try JSONSerialization.data(withJSONObject: propsDict, options: [.prettyPrinted])
        propertiesStr = String(data: data, encoding: .utf8)!
    }
    
    func restoreComponent() -> TEComponent2D {
        let type = TEComponentsRegister2D.shared.registredComponents[className]
        guard let type else { return TEMissedComponent2D() }
        

        guard let propsData = propertiesStr.data(using: .utf8) else {
            TELogger2D.print("could not get components data as String")
            return TEMissedComponent2D()
        }
        guard let propsDict = try? JSONSerialization.jsonObject(with: propsData) as? [String: Any] else {
            TELogger2D.print("could not get props data as [String: Any]")
            return TEMissedComponent2D()
        }
        return type.decoded(from: propsDict) ?? TEMissedComponent2D()
    }
    
    private enum CodingKeys: String, CodingKey {
        case className
        case propertiesStr
    }
    
    // MARK: - Encodable
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(className, forKey: .className)
        try container.encode(propertiesStr, forKey: .propertiesStr)
    }
    
    // MARK: - Decodable
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.className = try container.decode(String.self, forKey: .className)
        self.propertiesStr = try container.decode(String.self, forKey: .propertiesStr)
    }
}
