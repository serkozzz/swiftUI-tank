// The Swift Programming Language
// https://docs.swift.org/swift-book


@MainActor
public class TETankEngine2D {
    public static var shared = TETankEngine2D()
    public private(set) var scene: TEScene2D?
    
    
    private init() {
    }
    
    public func start(scene: TEScene2D) {
        self.scene = scene
    }
    
    public func stop() {
        
    }
}
