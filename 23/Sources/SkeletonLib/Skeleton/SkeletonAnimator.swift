//
//  SkeletonAnimator.swift
//  try-reality-kit
//
//  Created by fuziki on 2022/08/13
//
//

import Foundation
import RealityKit

public class SkeletonAnimator<Definition: SkeletonDefinitionProtocol> {
    public var target: ModelEntity? {
        didSet {
            reset()
        }
    }
    public var defaultJointTransforms: [Transform]?

    private let definition: Definition
    public init(definition: Definition) {
        self.definition = definition
    }
    public func set(joint: SkeletonJoint, rotation: simd_quatf) {
        guard target?.jointTransforms != nil,
              defaultJointTransforms != nil else {
            return
        }
        let i = definition.index(for: joint)
        target?.jointTransforms[i].rotation = rotation
    }

    public func set(joint: SkeletonJoint, rotateFromNeutral rotation: simd_quatf) {
        guard target?.jointTransforms != nil,
              let defaultJointTransforms = defaultJointTransforms else {
            return
        }
        let i = definition.index(for: joint)
        target?.jointTransforms[i].rotation = defaultJointTransforms[i].rotation * rotation
    }

    public func update() {
        guard let jointTransform = target?.jointTransforms,
              jointTransform.count > 0 else {
            return
        }
        if defaultJointTransforms == nil {
            defaultJointTransforms = jointTransform
        }
    }

    private func reset() {
        defaultJointTransforms = nil
    }
}
