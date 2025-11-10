//
//  TEPreviewable2D+BaseTypes.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 10.11.2025.
//

import Foundation
import CoreGraphics
import SwiftUI
import simd

// Базовые числовые и строковые типы
extension Int: TEPreviewable2D {}
extension Float: TEPreviewable2D {}
extension Double: TEPreviewable2D {}
extension Bool: TEPreviewable2D {}
extension String: TEPreviewable2D {}

// CoreGraphics
extension CGFloat: TEPreviewable2D {}
extension CGPoint: TEPreviewable2D {}
extension CGSize: TEPreviewable2D {}
extension CGRect: TEPreviewable2D {}


// SIMD
extension SIMD2: TEPreviewable2D where Scalar == Float {}
extension SIMD3: TEPreviewable2D where Scalar == Float {}

extension Matrix: TEPreviewable2D {}
