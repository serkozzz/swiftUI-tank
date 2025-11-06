//
//  SceneSaver.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 28.10.2025.
//
import Foundation

@MainActor
public class TESceneSaver2D {
    
    public init() {}
    public func save(_ scene: TEScene2D) -> Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        do {
            let data = try encoder.encode(scene)
            let jsonString = String(data: data, encoding: .utf8)!
            print(jsonString)
            return data
        }
        catch {
            print("SceneSaver.save error: \(error)")
        }
        return nil
    }
    
    public func load(jsonData: Data) -> TEScene2D? {
        
        let linker = TESceneLinker()
        let decoder = JSONDecoder()
        decoder.userInfo[.componentsLinker2D] = linker
        
        do {
            let scene = try decoder.decode(TEScene2D.self, from: jsonData)
            linker.resolveLinks(scene: scene)
            
            let encoder = JSONEncoder()
            encoder.outputFormatting.insert(.prettyPrinted)
            let newData = try encoder.encode(scene)
            let newJsonString = String(data: newData, encoding: .utf8)!
            print(newJsonString)
            scene.printGraph()
            return scene
        }
        catch {
            print("SceneSaver.save error: \(error)")
        }
        return nil
    }
}
