//
//  TEOBB.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 12.10.2025.
//

import simd
import SwiftUI

@MainActor
// Oriented Bounding Box in 2D: center + halfSize + two orthonormal axes in world space.
struct TEOBB {
    var center: SIMD2<Float>
    var halfSize: SIMD2<Float>  // (halfWidth, halfHeight)
    var axis: (SIMD2<Float>, SIMD2<Float>) // two orthonormal axes (xAxis, yAxis) in world space

    init(center: SIMD2<Float>, size: CGSize, xAxis: SIMD2<Float>, yAxis: SIMD2<Float>) {
        self.center = center
        self.halfSize = SIMD2<Float>(Float(size.width) * 0.5, Float(size.height) * 0.5)
        // Normalize axes to be safe
        let nx = simd_normalize(xAxis)
        let ny = simd_normalize(yAxis)
        self.axis = (nx, ny)
    }

    // Build OBB from a world transform (column-major, T * R) and a size (width, height).
    init(worldTransform: TETransform2D, size: CGSize) {
        let m = worldTransform.matrix
        // columns.0.xy and columns.1.xy are the rotated basis vectors in world space
        let xAxis = SIMD2<Float>(m.columns.0.x, m.columns.0.y)
        let yAxis = SIMD2<Float>(m.columns.1.x, m.columns.1.y)
        self.init(center: worldTransform.position, size: size, xAxis: xAxis, yAxis: yAxis)
    }

    // 4 world-space corners of the OBB
    var corners: [SIMD2<Float>] {
        let (ax, ay) = axis
        let dx = ax * halfSize.x
        let dy = ay * halfSize.y
        // center ± dx ± dy
        return [
            center + dx + dy,
            center + dx - dy,
            center - dx + dy,
            center - dx - dy
        ]
    }
}

// MARK: - SAT intersection (OBB vs OBB)
extension TEOBB {
    // Project this OBB onto axis 'a' (unit vector).
    private func projectionRadius(on a: SIMD2<Float>) -> Float {
        let (ax, ay) = axis
        // radius = |halfSize.x * dot(a, ax)| + |halfSize.y * dot(a, ay)|
        return abs(halfSize.x * simd_dot(a, ax)) + abs(halfSize.y * simd_dot(a, ay))
    }

    // SAT test against another OBB
    func intersects(_ other: TEOBB) -> Bool {
        // Small tolerance to treat touching as intersection and to be robust to float error
        let epsilon: Float = 1e-5

        // 4 axes to test: this.axis.0, this.axis.1, other.axis.0, other.axis.1
        let axesToTest: [SIMD2<Float>] = [axis.0, axis.1, other.axis.0, other.axis.1].map { simd_normalize($0) }

        let c = other.center - self.center

        for a in axesToTest {
            let dist = abs(simd_dot(c, a))
            let r1 = self.projectionRadius(on: a)
            let r2 = other.projectionRadius(on: a)
            // Consider separated only if there is a clear gap beyond epsilon
            if dist > (r1 + r2 + epsilon) {
                return false // Separating axis found
            }
        }
        return true
    }

    // Check that all corners of this OBB lie inside an axis-aligned AABB (inclusive)
    func isFullyInsideAABB(_ bounds: TEAABB) -> Bool {
        for p in corners {
            if p.x < bounds.min.x || p.x > bounds.max.x { return false }
            if p.y < bounds.min.y || p.y > bounds.max.y { return false }
        }
        return true
    }
}

