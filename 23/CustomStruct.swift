//
//  CustomStruct.swift
//  23
//
//  Created by Paul Chartier on 16/01/2023.
//

import Foundation
import UIKit
import RealityKit
import ARKit
import Combine
import MultipeerConnectivity

struct CustomStruct: Codable {
    let name: String
    let matrix: simd_float4x4
    
    init(name: String, matrix: simd_float4x4) {
        self.name = name
        self.matrix = matrix
    }
}

extension simd_float4x4: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        try self.init(container.decode([SIMD4<Float>].self))
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode([columns.0,columns.1, columns.2, columns.3])
    }
}

extension Array where Element == Float {
    
    /// Converts array of 16 Floats to a simd_float4x4 matrix
    func toSimdFloat4x4() -> simd_float4x4 {
        if self.count == 16 {
            let c0 = SIMD4(self[0], self[1], self[2], self[3])
            let c1 = SIMD4(self[4], self[5], self[6], self[7])
            let c2 = SIMD4(self[8], self[9], self[10], self[11])
            let c3 = SIMD4(self[12], self[13], self[14], self[15])
            return simd_float4x4([c0, c1, c2, c3])
        } else {
            // not valid input, return empty matrix
            return simd_float4x4()
        }
    }
    
    /// Converts array of 16 Floats to a SCNMatrix4 matrix
    func toSCNMatrix4() -> SCNMatrix4 {
        if self.count == 16 {
            let simd = self.toSimdFloat4x4()
            return SCNMatrix4(simd)
        } else {
            return SCNMatrix4()
        }
    }
 }
