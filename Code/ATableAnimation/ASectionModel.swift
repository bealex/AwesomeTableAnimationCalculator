//
// Created by Alexander Babaev on 17.04.16.
// Copyright (c) 2016 Alexander Babaev, LonelyBytes. All rights reserved.
// Sources: https://github.com/bealex/AwesomeTableAnimationCalculator
// License: MIT https://github.com/bealex/AwesomeTableAnimationCalculator/blob/master/LICENSE
//

import Foundation

/**
    This protocol is needed because I want to provide two versions
    of the base class: Swift and Objective-C supported.
 */
public protocol ASectionModelProtocol {
    var startIndex: Int { get }
    var endIndex: Int { get }

    func update(startIndex: Int, endIndex: Int)
}

/**
    Here is the pure Swift version
 */
open class ASectionModel: ASectionModelProtocol {
    open internal (set) var startIndex: Int = 0
    open internal (set) var endIndex: Int = 0

    public init() {}
}

/**
    This version must be used for Objective-C supported classes
 */
open class ASectionModelObjC: NSObject, ASectionModelProtocol {
    open internal (set) var startIndex: Int = 0
    open internal (set) var endIndex: Int = 0
}
