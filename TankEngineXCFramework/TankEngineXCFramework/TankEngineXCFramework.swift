//
//  TankEngineXCFramework.swift
//  TankEngineXCFramework
//
//  Created by Sergey Kozlov on 26.11.2025.
//

import Foundation


public func testBridge() {
    // Will compile once test.h is a Public header and included by the umbrella header.
    let s = testBridgeString()
    print("Received from Objective-C: \(s)")
}
