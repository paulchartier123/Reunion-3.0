//
//  SkeletonDefinition.swift
//  try-reality-kit
//
//  Created by fuziki on 2022/08/12
//
//

import Foundation

public protocol SkeletonDefinitionProtocol {
    func index(for joint: SkeletonJoint) -> Int
}

public enum SkeletonDefinition {
}

/*
extension SkeletonDefinition {
    public static let sample = SampleSkeletonDefinition()
}

public class SampleSkeletonDefinition: SkeletonDefinitionProtocol {
    public func index(for joint: SkeletonJoint) -> Int {
        return 0
    }
}
*/
