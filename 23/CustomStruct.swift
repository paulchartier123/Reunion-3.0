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
