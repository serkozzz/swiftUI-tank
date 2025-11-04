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
    public func save(_ scene: TEScene2D) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        do {
            let data = try encoder.encode(scene)
//            let jsonString = String(data: data, encoding: .utf8)!
//            print(jsonString)
            
            let newScene = try JSONDecoder().decode(TEScene2D.self, from: data)
            let newData = try encoder.encode(newScene)
            let newJsonString = String(data: newData, encoding: .utf8)!
            print(newJsonString)
        }
        catch {
            print("SceneSaver.save error: \(error)")
        }
    }
    
    public func load(jsonData: Data) -> TEScene2D? {
        let decoder = JSONDecoder()
        do {
            let scene = try decoder.decode(TEScene2D.self, from: jsonData)
            scene.printGraph()
            return scene
        }
        catch {
            print("SceneSaver.save error: \(error)")
        }
        return nil
    }
}
