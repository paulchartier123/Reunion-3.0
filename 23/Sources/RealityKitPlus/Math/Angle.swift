//
//  File.swift
//  
//  
//  Created by fuziki on 2022/08/16
//  
//

import Foundation

fileprivate let _2pi: Float = 2 * .pi

// return -pi ~ pi
public func angleDiff(a: Float, b: Float) -> Float {
    let b = angleNorm1(a: b)
    let a = angleNorm1(a: a)
    return angleNorm2(a: b - a)
}

// return 0 ~ 2pi
internal func angleNorm1(a: Float) -> Float {
    a - floor(a / _2pi) * _2pi
}

// return -pi ~ pi
internal func angleNorm2(a: Float) -> Float {
    var n = angleNorm1(a: a)
    if n > .pi {
        n -= _2pi
    }
    return n
}
